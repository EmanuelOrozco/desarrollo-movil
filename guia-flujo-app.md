# Guía de estudio: flujo de la app de productos

Esta guía explica qué hace cada archivo de la app, en qué momento entra y para qué sirve. Está escrita para leerla sin saber Flutter de memoria: cada término raro se traduce al lado.

Al final hay un glosario y preguntas para repasar antes del examen.

---

## 1. Mapa rápido de archivos

| Archivo | Para qué existe | ¿La pantalla lo usa ya? |
|---|---|---|
| `lib/main.dart` | Arranca la app, pone el tema azul y abre la lista | Sí, es el inicio |
| `lib/product_screen.dart` | Pantalla de la lista: pide datos, arma la cuadrícula, guarda el favorito | Sí |
| `lib/services/product_services.dart` | Pide los productos a internet y convierte la respuesta | Sí |
| `lib/models/product.dart` | La ficha de un producto (nombre, precio, id, etc.) | Sí |
| `lib/itemCard.dart` | Dibuja una tarjeta de la cuadrícula | Sí |
| `lib/products_detail.dart` | Pantalla de detalle de un solo producto | Sí, al tocar una tarjeta |
| `lib/models/product_note.dart` | La ficha de una nota (texto, puntuación, fecha) | No todavía |
| `lib/services/product_note_storage.dart` | Guarda esas notas en un archivo del teléfono | No todavía |
| `pubspec.yaml` | Lista las librerías que la app necesita | Sí, al compilar |

Las librerías que importan para el examen están en `pubspec.yaml`:

- `http`: hablar con internet.
- `shared_preferences`: guardar un dato pequeño en el teléfono (el id del favorito).
- `path_provider`: encontrar la carpeta de documentos de la app (la usarían las notas).

---

## 2. El recorrido al abrir la app

1. `main.dart` arranca todo. Quita la cinta de «debug», pone el tema azul y dice que la primera pantalla es `ProductScreen`.
2. `product_screen.dart` es esa primera pantalla. En cuanto aparece hace dos cosas a la vez:
   - le pide la lista de productos a `ProductServices`;
   - lee en el teléfono si ya había un favorito guardado.
3. Mientras espera, muestra una rueda de carga. Si el servidor falla, muestra el error y el botón **Reintentar**. Si la lista llega vacía, dice «No hay productos». Si llega bien, cuenta el ancho de la pantalla y arma la cuadrícula.
4. Cada casilla de esa cuadrícula es `itemCard.dart`: estrella, nombre y precio.
5. El texto que llega de internet (el JSON) se convierte en objetos `Product` gracias a `models/product.dart`.

En una frase:

```text
main  →  ProductScreen  →  ProductServices (internet)
                         →  shared_preferences (favorito guardado)
                         →  ItemCard por cada producto
                         →  al tocar una tarjeta: ProductsDetail
```

---

## 3. `lib/main.dart` — la puerta de entrada

No muestra productos. Solo crea la aplicación y abre la pantalla principal.

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const ProductScreen(),
    );
  }
}
```

Qué hay que recordar:

- `main()` es lo primero que se ejecuta. `runApp` pone la app en pantalla.
- `StatelessWidget`: esta pantalla no guarda datos que cambien. Solo describe cómo se ve.
- `MaterialApp` es el contenedor de la app (tema, pantalla inicial, navegación).
- `debugShowCheckedModeBanner: false` esconde la cinta roja de «DEBUG».
- `theme` genera una paleta azul. Las otras pantallas leen esos colores con `Theme.of(context).colorScheme`.
- `home: const ProductScreen()` es la primera pantalla que ves.

---

## 4. `lib/models/product.dart` — la ficha de un producto

El servidor manda texto. La app necesita un objeto con campos con nombre. Esta clase es esa ficha.

```dart
class Product {
  int? id;
  String name;
  double price;
  int inventory;
  String category;
  bool isAvailable;
  String imagePath;
  String description;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.inventory,
    required this.category,
    required this.isAvailable,
    required this.imagePath,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      inventory: json['inventory'] as int,
      category: json['category'] as String,
      isAvailable: json['isAvailable'] as bool,
      imagePath: json['imagePath'] as String,
      description: json['description'] as String,
    );
  }
}
```

Qué hay que recordar:

- `id` puede ser nulo (`int?`) porque el constructor lo deja opcional (`this.id`). El resto es obligatorio (`required`).
- `fromJson` es una fábrica: recibe un mapa (un objeto JSON ya convertido) y devuelve un `Product`.
- El precio llega como número genérico (`num`) y se pasa a `double` con `.toDouble()`, porque en JSON un precio puede venir como `99` o como `99.5`.
- El favorito se compara con `product.id`. Por eso el id existe.

Ejemplo de lo que llega y en qué se convierte:

```json
{ "id": 3, "name": "Nintendo Switch OLED", "price": 349, "inventory": 85,
  "category": "Console", "isAvailable": true,
  "imagePath": "assets/images/switch_nintendo.webp",
  "description": "Consola híbrida..." }
```

Eso, pasado por `Product.fromJson`, es un objeto con `.name`, `.price`, `.id`, etc.

---

## 5. `lib/services/product_services.dart` — hablar con internet

Esta clase no dibuja nada. Pide la lista y la devuelve como `List<Product>`, o lanza un error entendible.

```dart
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ProductServices {
  final String baseUrl;

  ProductServices({required this.baseUrl});

  Future<List<Product>> getProducts() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        throw const ApiException('Not found');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException('Error HTTP: ${response.statusCode}');
    } on TimeoutException {
      throw const ApiException('Timeout');
    }
  }
}
```

Qué hay que recordar, paso a paso:

1. `baseUrl` es la dirección. La pantalla se la pasa al crear el servicio.
2. `http.get` hace la petición. `await` espera la respuesta sin congelar la interfaz.
3. `.timeout(10 segundos)` corta la espera. Si se pasa, entra en `on TimeoutException` y el error es `'Timeout'`.
4. Código 404 → error `'Not found'`.
5. Código 200 → el cuerpo es texto JSON. `jsonDecode` lo vuelve una lista. Cada elemento pasa por `Product.fromJson`.
6. Cualquier otro código → `'Error HTTP: 500'` (o el número que sea).
7. `Future<List<Product>>` significa: «ahora no tengo la lista; te la daré cuando termine». Por eso la pantalla usa un `FutureBuilder`.

La dirección que usa la pantalla es:

```dart
_service = ProductServices(
  baseUrl: 'https://dummyjson.com/c/b7c3-d875-45ac-ab06',
);
_futureProducts = _service.getProducts();
```

Eso ocurre en `initState`, que se ejecuta una vez, cuando la pantalla nace.

---

## 6. `lib/product_screen.dart` — el director de la lista

Esta pantalla guarda datos que cambian (el favorito, y si la lista ya llegó). Por eso es un `StatefulWidget`: tiene un estado (`_ProductScreenState`) que se puede actualizar con `setState`.

### 6.1 Al nacer: pedir productos y leer el favorito

```dart
int? favoriteId;

late final ProductServices _service;
late Future<List<Product>> _futureProducts;

@override
void initState() {
  super.initState();
  _service = ProductServices(
    baseUrl: 'https://dummyjson.com/c/b7c3-d875-45ac-ab06',
  );
  _futureProducts = _service.getProducts();
  loadFavoriteId();
}
```

- `favoriteId` es el id del producto con estrella. `int?` porque puede no haber favorito (`null`).
- `late` significa: «este valor se asigna un poco después de crear el objeto, pero antes de usarlo». Aquí se asigna en `initState`.

### 6.2 Reintentar si falló

```dart
void retryProducts() {
  setState(() {
    _futureProducts = _service.getProducts();
  });
}
```

`setState` avisa a Flutter: «cambié datos, vuelve a dibujar». Al crear un `Future` nuevo, el `FutureBuilder` vuelve a esperar y muestra otra vez la rueda de carga.

### 6.3 La estrella: cambiar y guardar

```dart
void toggleFavorite(int productId) {
  setState(() {
    favoriteId = favoriteId == productId ? null : productId;
    saveFavoriteId();
  });
}

Future<void> saveFavoriteId() async {
  final prefs = await SharedPreferences.getInstance();
  if (favoriteId == null) {
    await prefs.remove('favoriteId');
  } else {
    await prefs.setInt('favoriteId', favoriteId!);
  }
}

Future<void> loadFavoriteId() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    favoriteId = prefs.getInt('favoriteId');
  });
}
```

La lógica de la estrella, en español:

- Si tocas el que ya es favorito, `favoriteId` pasa a `null` (se apaga).
- Si tocas otro, `favoriteId` pasa a ser ese id (se enciende ese y se apaga el anterior). Solo hay un favorito.
- `saveFavoriteId` escribe el número en el teléfono con la clave `'favoriteId'`. Si no hay favorito, borra esa clave.
- `loadFavoriteId` lee esa clave al abrir la app. `getInt` devuelve `null` si nunca se guardó nada.
- `favoriteId!` es «estoy seguro de que aquí no es null», porque acaba de entrar al `else`.

`SharedPreferences` es un cuaderno pequeño del teléfono para valores simples (un número, un texto, un sí/no). Sobrevive a cerrar la app.

### 6.4 Cuántas columnas, según el ancho

```dart
int _columnCount(double width) {
  if (width >= 900) return 5;
  if (width >= 700) return 4;
  if (width >= 500) return 3;
  if (width >= 300) return 2;
  return 1;
}
```

| Ancho | Columnas |
|---|---|
| 900 px o más | 5 |
| 700 px o más | 4 |
| 500 px o más | 3 |
| 300 px o más | 2 |
| menos de 300 px | 1 |

En un celular caben pocas columnas. En una pantalla ancha, más.

### 6.5 Abrir el detalle

```dart
void openProductDetail(Product product) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProductsDetail(product: product)),
  );
}
```

`Navigator.push` pone una pantalla nueva encima. La lista se queda detrás. La flecha de atrás la quita y vuelves a la lista. El detalle recibe el mismo `Product` que ya se descargó: no vuelve a llamar al servidor.

### 6.6 Dibujar carga, error, vacío o cuadrícula

```dart
Widget _buildBody() {
  return FutureBuilder<List<Product>>(
    future: _futureProducts,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Error al cargar los productos'),
              TextButton(
                onPressed: retryProducts,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      }

      final products = snapshot.data ?? [];

      if (products.isEmpty) {
        return const Center(child: Text('No hay productos'));
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = _columnCount(constraints.maxWidth);

          return GridView.builder(
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              final bool isFavorite = product.id == favoriteId;
              return ItemCard(
                product: product,
                onTap: () {
                  openProductDetail(product);
                },
                isFavorite: isFavorite,
                onFavoriteTap: () {
                  toggleFavorite(product.id!);
                },
              );
            },
          );
        },
      );
    },
  );
}
```

`FutureBuilder` mira el `Future` y dibuja según en qué momento esté:

| Situación | Qué ves |
|---|---|
| `waiting` | Rueda de carga (`CircularProgressIndicator`) |
| `hasError` | Texto de error + botón Reintentar |
| lista vacía | «No hay productos» |
| lista con datos | Cuadrícula de `ItemCard` |

Detalles que suelen preguntar:

- `snapshot.data ?? []` : si todavía no hay datos, usa una lista vacía.
- `LayoutBuilder` mide el ancho real disponible (`constraints.maxWidth`) y con eso elige las columnas.
- `GridView.builder` crea solo las tarjetas que hacen falta, una por producto (`itemCount`).
- `crossAxisSpacing` y `mainAxisSpacing` son el hueco entre tarjetas (12).
- `childAspectRatio: 0.75` hace cada celda un poco más alta que ancha.
- `isFavorite` es verdadero solo cuando el id del producto coincide con `favoriteId`.
- La tarjeta no decide la navegación ni el guardado. Solo llama a `onTap` y `onFavoriteTap`, que son funciones que le pasó esta pantalla.

La pantalla en sí es un `Scaffold`: barra de arriba con el título «Productos» y, debajo, el cuerpo con un padding de 16.

```dart
return Scaffold(
  appBar: AppBar(title: const Text('Productos')),
  body: Padding(padding: const EdgeInsets.all(16), child: _buildBody()),
);
```

---

## 7. `lib/itemCard.dart` — una tarjeta

Solo dibuja. No pide datos y no los guarda. Recibe cuatro cosas:

| Parámetro | Qué es |
|---|---|
| `product` | La ficha a mostrar |
| `onTap` | Qué hacer al tocar la tarjeta (abrir detalle). Puede ser nulo |
| `isFavorite` | Si la estrella va rellena. Por defecto `false` |
| `onFavoriteTap` | Qué hacer al tocar la estrella. Obligatorio |

```dart
class ItemCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                iconSize: 24,
                color: isFavorite ? Colors.yellow : Colors.black,
                onPressed: onFavoriteTap,
                icon: Icon(isFavorite ? Icons.star : Icons.star_border),
              ),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text('${product.price} USD'),
            ],
          ),
        ),
      ),
    );
  }
}
```

Qué hay que recordar:

- Es `StatelessWidget` porque no guarda estado propio. El favorito vive en `ProductScreen` y se lo pasan ya calculado.
- `InkWell` hace que toda la tarjeta sea tocable y muestre la onda al pulsar.
- `margin: EdgeInsets.zero` quita el margen de la tarjeta. El hueco lo pone la cuadrícula (`spacing: 12`), para no sumar dos márgenes.
- Estrella amarilla y rellena si `isFavorite` es true. Contorno negro si es false.
- El nombre se corta a 2 líneas con `...` (`maxLines` + `TextOverflow.ellipsis`).
- `IconButton.onPressed` es la estrella. `InkWell.onTap` es el resto de la tarjeta. Son dos gestos distintos.

---

## 8. `lib/products_detail.dart` — la ficha grande

Segunda pantalla. Recibe un `Product` y lo muestra. No llama a `ProductServices`.

Aunque hoy no cambia datos internos, está escrita como `StatefulWidget`. Dentro del `build` se lee el producto con `widget.product` (en un `State`, el widget que te creó se llama `widget`).

Estructura de lo que ves, de arriba abajo:

1. Barra con el nombre, centrado y en negrita.
2. Fondo tomado del tema (`colors.surfaceContainerLow`).
3. Contenido con scroll (`SingleChildScrollView`), por si la descripción es larga.
4. El bloque se centra y no pasa de 600 px de ancho (`maxWidth: 600`), para que en una pantalla grande no se estire de lado a lado.
5. Imagen dentro de una tarjeta, proporción 16:9, máximo 260 px de ancho.
6. Si la imagen falla, un icono (`Icons.movie_outlined`) sobre un fondo del tema.
7. Nombre grande, precio, dos etiquetas (`Chip`) y la descripción.

La imagen y el plan B si no carga:

```dart
Image.asset(
  widget.product.imagePath,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size: 72,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  },
)
```

`Image.asset` busca un archivo dentro del proyecto (por ejemplo `assets/images/switch_nintendo.webp`), no una URL de internet. `BoxFit.cover` recorta la foto para llenar el recuadro sin deformarla. `errorBuilder` se ejecuta solo si ese archivo no se encuentra.

Las dos etiquetas:

```dart
Chip(
  avatar: const Icon(Icons.computer_outlined, size: 18),
  label: Text(widget.product.category),
  backgroundColor: colors.secondaryContainer,
),
Chip(
  avatar: Icon(
    widget.product.isAvailable
        ? Icons.check_circle_outline
        : Icons.schedule,
    size: 18,
  ),
  label: Text(
    widget.product.isAvailable ? 'Disponible' : 'Agotado',
  ),
  backgroundColor: colors.surfaceContainerHighest,
),
```

- Primera etiqueta: la categoría (`Console`, `Laptop`, etc.), con icono de computadora y color secundario del tema.
- Segunda etiqueta: si `isAvailable` es true, icono de check y texto «Disponible». Si es false, icono de reloj y texto «Agotado».

La descripción usa `colors.onSurfaceVariant` para verse un poco más suave que el título, con interlineado `height: 1.6`.

---

## 9. Qué pasa cuando tocas algo

### Tocas la tarjeta

```text
ItemCard (InkWell.onTap)
    → ProductScreen.openProductDetail(product)
        → Navigator.push
            → ProductsDetail(product: ese mismo producto)
```

La lista sigue viva detrás. Al volver, el favorito sigue como estaba, porque vive en el estado de `ProductScreen`.

### Tocas la estrella

```text
ItemCard (IconButton.onPressed)
    → ProductScreen.toggleFavorite(product.id)
        → favoriteId cambia (o pasa a null)
        → setState redibuja la cuadrícula
        → saveFavoriteId escribe o borra 'favoriteId' en SharedPreferences
```

La próxima vez que abras la app:

```text
initState
    → loadFavoriteId
        → prefs.getInt('favoriteId')
            → setState
                → la estrella vuelve a pintarse en ese producto
```

---

## 10. Archivos que existen y todavía no entran en el recorrido

Ninguna pantalla importa estas clases. Al usar la app, el archivo de notas no se crea. Están preparados para una función futura: anotar y puntuar un producto.

### `lib/models/product_note.dart`

```dart
class ProductNote {
  final int productId;
  final String note;
  final int rating;
  final DateTime updatedAt;

  factory ProductNote.fromJson(Map<String, dynamic> json) { /* ... */ }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'note': note,
        'rating': rating,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
```

Diferencia con `Product`:

- `Product` solo sabe leer JSON (`fromJson`), porque los productos llegan del servidor y la app no los reescribe.
- `ProductNote` sabe leer (`fromJson`) y escribir (`toJson`), porque la app los guarda en el teléfono.
- `toIso8601String()` guarda la fecha como texto estándar, por ejemplo `2026-09-27T18:26:00.000`. `DateTime.parse` la vuelve a convertir en fecha al leer.

### `lib/services/product_note_storage.dart`

Guarda una lista de notas en `product_notes.json`, dentro de la carpeta de documentos de la app (`path_provider` → `getApplicationDocumentsDirectory`).

| Método | Qué hace |
|---|---|
| `_getFile()` | Arma la ruta del archivo |
| `_readAll()` | Si el archivo no existe o está vacío, devuelve `[]`. Si existe, lo convierte en `List<ProductNote>` |
| `_writeAll(notes)` | Convierte la lista a JSON y la escribe encima del archivo |
| `getNote(productId)` | Busca la nota de ese producto. Si no hay, devuelve `null` |
| `saveNote(note)` | Si ya había nota de ese id, la reemplaza. Si no, la agrega. Luego escribe el archivo |
| `deleteNote(productId)` | Quita la nota de ese id y vuelve a escribir el archivo |

El patrón de `saveNote` es el que más se pregunta:

```dart
Future<void> saveNote(ProductNote note) async {
  final notes = await _readAll();
  final index = notes.indexWhere((n) => n.productId == note.productId);

  if (index >= 0) {
    notes[index] = note;   // ya existía: se actualiza
  } else {
    notes.add(note);       // no existía: se agrega
  }

  await _writeAll(notes);
}
```

`indexWhere` devuelve la posición (0, 1, 2...) o `-1` si no encontró ese `productId`.

---

## 11. Glosario corto

| Palabra | En cristiano |
|---|---|
| Widget | Un trozo de pantalla: un texto, un botón, una tarjeta, una pantalla entera |
| `StatelessWidget` | Trozo que solo dibuja lo que le pasan. No recuerda cambios propios |
| `StatefulWidget` | Trozo que sí recuerda datos (el favorito, la lista en curso) y puede redibujarse |
| `State` / `setState` | El cuaderno de esos datos. `setState` dice «cambié algo, vuelve a dibujar» |
| `initState` | Se ejecuta una vez al crear la pantalla. Aquí se lanza la petición y se lee el favorito |
| `build` | La función que describe qué se ve. Flutter la vuelve a llamar después de cada `setState` |
| `Future` | Una tarea que termina después (la petición HTTP, leer el favorito) |
| `async` / `await` | `async` marca una función que espera. `await` pausa esa función hasta que el `Future` termina, sin congelar la app |
| `FutureBuilder` | Widget que dibuja carga, error o datos según cómo vaya un `Future` |
| JSON | Texto con datos, con llaves y listas. Lo manda el servidor y lo leen `jsonDecode` + `fromJson` |
| `Navigator.push` | Abre otra pantalla encima de la actual |
| `Scaffold` | Esqueleto de pantalla: barra superior (`AppBar`) + cuerpo (`body`) |
| `SharedPreferences` | Almacén pequeño y permanente para un número, un texto o un booleano |
| Código HTTP 200 | El servidor respondió bien |
| Código HTTP 404 | No se encontró lo que pediste |
| Timeout | Pasaron 10 segundos y no hubo respuesta |

---

## 12. Preguntas para repasarte

1. ¿Quién arranca la app y qué pantalla abre?
2. ¿En qué momento se llama a `getProducts`? ¿Y si el usuario pulsa Reintentar?
3. ¿Qué devuelve `getProducts` cuando todo sale bien? ¿Qué lanza si tarda más de 10 segundos?
4. ¿Por qué `Product.fromJson` convierte el precio con `toDouble()`?
5. ¿Dónde vive `favoriteId`? ¿Por qué `ItemCard` no lo guarda ella?
6. ¿Qué pasa si tocas la estrella del producto que ya era favorito?
7. ¿Qué clave usa `SharedPreferences` y qué tipo de dato guarda?
8. ¿Cuántas columnas hay si el ancho es 650? ¿Y si es 200?
9. ¿El detalle vuelve a descargar el producto? ¿De dónde saca el nombre y la foto?
10. ¿Qué hace `errorBuilder` de la imagen?
11. ¿Por qué `ProductNote` tiene `toJson` y `Product` no?
12. Si guardas una nota de un producto que ya tenía nota, ¿se duplica o se reemplaza? ¿Qué línea lo decide?

Respuestas cortas:

1. `main()` → `MyApp` → `home: ProductScreen()`.
2. En `initState`, al crear la pantalla. Reintentar llama a `retryProducts`, que vuelve a asignar `_futureProducts = _service.getProducts()` dentro de `setState`.
3. `List<Product>`. Lanza `ApiException('Timeout')`.
4. Porque el JSON puede traer el precio como entero o como decimal, y el campo `price` es `double`.
5. En `_ProductScreenState`. La tarjeta es `StatelessWidget`: le pasan `isFavorite` ya calculado (`product.id == favoriteId`).
6. `favoriteId` pasa a `null`, se borra la clave `'favoriteId'` y la estrella queda vacía.
7. La clave es `'favoriteId'`. Guarda un `int` con `setInt`. Si no hay favorito, `remove`.
8. 650 está entre 500 y 700, así que 3 columnas. 200 es menor que 300, así que 1 columna.
9. No lo descarga otra vez. Usa el `Product` que `Navigator.push` le pasó.
10. Si `Image.asset` no encuentra el archivo, dibuja un icono en lugar de romper la pantalla.
11. Los productos solo se leen del servidor. Las notas se escriben en un archivo local, así que necesitan convertirse de vuelta a JSON.
12. Se reemplaza. `indexWhere` encuentra la posición y `notes[index] = note` pisa la anterior. Solo hace `notes.add` cuando el índice es `-1`.
