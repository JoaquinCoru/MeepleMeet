# MeepleMeet

Aplicación nativa en **SwiftUI** para MeepleMeet, una plataforma social para descubrir juegos de mesa, gestionar una ludoteca y organizar quedadas para jugar.

> **Estado: catálogo conectado.** La aplicación incluye navegación, una lista de juegos con estado de carga y la primera integración de red con MeepleMeet API.

## Resumen

MeepleMeet es el cliente iOS del proyecto final del Swift Mastery Program. La primera versión establece el punto de entrada de la aplicación, una barra de pestañas con las cinco áreas principales y una vista independiente para cada sección. Cada pestaña tiene su propio `NavigationStack`, preparada para añadir navegación interna a medida que crezcan las funcionalidades.

El cliente consume el endpoint público de catálogo `GET /api/v1/games` del servidor `MeepleMeetAPI`, desarrollado con Vapor en un directorio hermano.

## Estado actual

- [x] Crear el proyecto Xcode `MeepleMeet`.
- [x] Añadir las pestañas Inicio, Juegos, Quedadas, Ludoteca y Perfil.
- [x] Separar cada pantalla en su propio archivo SwiftUI.
- [x] Crear el componente de fila de juego y un modelo `Decodable` para el catálogo.
- [x] Añadir `GamesVM` y una preview del catálogo con `sampleData`.
- [x] Cargar el catálogo desde MeepleMeet API mediante `Mastery26`.
- [x] Compilar la app para iOS Simulator.
- [ ] Definir el diseño visual de las pantallas.
- [ ] Completar los campos de categoría, duración y número de usuarios propietarios en el contrato del backend.
- [ ] Añadir ludoteca personal, quedadas y perfil de usuario.
- [ ] Incorporar persistencia, autenticación y pruebas.

## Tecnologías

- Swift 6 language mode con concurrencia estricta
- SwiftUI
- Xcode 26.6
- iOS 26 o posterior (requisito de la versión actual de Mastery26)
- Swift Package Manager para futuras dependencias
- Mastery26 como paquete local para las peticiones HTTP

El cliente usa un paquete local propio y no incorpora dependencias de terceros. Todavía no hay persistencia local.

## Requisitos

- macOS con Xcode 26.6 o posterior.
- Un destino de iOS 26 o posterior, físico o de simulador.

## Abrir y ejecutar

Abre `MeepleMeet.xcodeproj` en Xcode, selecciona el esquema **MeepleMeet** y ejecuta la aplicación en un simulador o dispositivo iOS.

Para cargar juegos, arranca `MeepleMeetAPI` en el Mac con `swift run`. En desarrollo, el cliente solicita `http://localhost:8080/api/v1/games`.

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
    ├── Interface/
    │   └── APIEndpoint.swift    # URL de la API
    ├── PreviewData/
    │   └── GamesSampleData.swift # Datos de muestra para previews
    ├── ViewModels/
    │   └── GamesVM.swift        # Estado del catálogo de juegos
    ├── Repository/
    │   └── RepositoryData.swift # Acceso a red con Mastery26
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

La pestaña Juegos descarga el catálogo al mostrarse por primera vez y ofrece reintentar si falla. Los datos de preview son locales y no activan la petición. La API actual no proporciona categoría ni cantidad de propietarios; esos campos se muestran cuando el backend los incluya. Persistencia, autenticación y otras funcionalidades de negocio siguen pendientes.
