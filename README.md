# MeepleMeet

Aplicación nativa en **SwiftUI** para MeepleMeet, una plataforma social para descubrir juegos de mesa, gestionar una ludoteca y organizar quedadas para jugar.

> **Estado: base de interfaz.** La aplicación incluye la navegación principal y el componente de fila del catálogo de juegos. La carga de datos desde la API todavía no está conectada.

## Resumen

MeepleMeet es el cliente iOS del proyecto final del Swift Mastery Program. La primera versión establece el punto de entrada de la aplicación, una barra de pestañas con las cinco áreas principales y una vista independiente para cada sección. Cada pestaña tiene su propio `NavigationStack`, preparada para añadir navegación interna a medida que crezcan las funcionalidades.

El proyecto está planteado como contraparte del servidor `MeepleMeetAPI`, desarrollado con Vapor en un directorio hermano. La comunicación entre ambos todavía no está implementada.

## Estado actual

- [x] Crear el proyecto Xcode `MeepleMeet`.
- [x] Añadir las pestañas Inicio, Juegos, Quedadas, Ludoteca y Perfil.
- [x] Separar cada pantalla en su propio archivo SwiftUI.
- [x] Crear el componente de fila de juego y un modelo `Decodable` para el catálogo.
- [x] Añadir `GamesVM` y una preview del catálogo con `sampleData`.
- [x] Compilar la app para iOS Simulator.
- [ ] Definir el diseño visual de las pantallas.
- [ ] Crear modelos de presentación y conectar el catálogo con MeepleMeet API.
- [ ] Añadir ludoteca personal, quedadas y perfil de usuario.
- [ ] Incorporar persistencia, autenticación y pruebas.

## Tecnologías

- Swift 6 language mode con concurrencia estricta
- SwiftUI
- Xcode 26.6
- iOS 17 o posterior
- Swift Package Manager para futuras dependencias

La base actual no incorpora dependencias externas ni persistencia local.

## Requisitos

- macOS con Xcode 26.6 o posterior.
- Un destino de iOS 17 o posterior, físico o de simulador.

## Abrir y ejecutar

Abre `MeepleMeet.xcodeproj` en Xcode, selecciona el esquema **MeepleMeet** y ejecuta la aplicación en un simulador o dispositivo iOS.

También puedes compilar desde Terminal:

```sh
xcodebuild \
  -project MeepleMeet.xcodeproj \
  -scheme MeepleMeet \
  -sdk iphonesimulator \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Para usar las previews de SwiftUI, utiliza la configuración **Debug**. El proyecto establece explícitamente `SWIFT_OPTIMIZATION_LEVEL = -Onone` para esa configuración.

## Estructura

```text
MeepleMeet/
├── MeepleMeet.xcodeproj/
│   └── xcshareddata/xcschemes/  # Esquema compartido de Xcode
└── MeepleMeet/
    ├── App/
    │   ├── AppTab.swift         # Identidad, título e icono de cada pestaña
    │   ├── MeepleMeet.swift  # Punto de entrada
    │   └── RootTabView.swift    # Navegación principal
    ├── Models/
    │   └── GameCatalogItem.swift # Modelo decodificable del catálogo
    ├── PreviewData/
    │   └── GamesSampleData.swift # Datos de muestra para previews
    ├── ViewModels/
    │   └── GamesVM.swift        # Estado del catálogo de juegos
    └── Views/
        ├── GameDetailView.swift
        ├── GameListItemView.swift
        ├── GameLibraryView.swift
        ├── GamesView.swift
        ├── HomeView.swift
        ├── MeetupsView.swift
        └── ProfileView.swift
```

## Próximos pasos

1. Acordar el lenguaje visual y diseñar Inicio, Juegos, Quedadas, Ludoteca y Perfil.
2. Añadir modelos y servicios de red para consumir el catálogo de MeepleMeet API.
3. Implementar las acciones principales de ludoteca y quedadas.
4. Incorporar autenticación y persistencia local según las necesidades del MVP.
5. Añadir pruebas y automatizar la compilación del proyecto.

## Alcance de esta base

La pestaña Juegos presenta el estado vacío hasta recibir elementos; su fila de catálogo está preparada para usar datos decodificados del backend y se muestra con datos de ejemplo solo en la preview. La carga de red, almacenamiento local, autenticación y otras funcionalidades de negocio todavía no están implementadas.
