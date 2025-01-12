# HealthApp - SwiftUI, HealthKit, Charts

## About

HealthApp is a SwiftUI application designed for educational purposes. It leverages HealthKit to track and visualize health data, including steps and weight. The app features interactive charts and a user-friendly interface, making it a comprehensive tool for learning about health data integration and visualization in iOS development.

## Project Structure
- **HealthApp/**: Contains the main application code.
  - **App.swift**: Entry point of the SwiftUI application.
  - **ContentView.swift**: Main user interface container.
  - **Models/**: Contains data models.
    - **HealthDataModel.swift**: Represents health data structure.
  - **Views/**: Contains all the UI components.
    - **DashboardView.swift**: Displays an overview of health metrics.
    - **NavigationView.swift**: Sets up the navigation structure.
    - **DataListView.swift**: Presents a list of health data entries.
    - **StepBarChartView.swift**: UI for the step bar chart.
    - **StepPieChartView.swift**: UI for the step pie chart.
    - **WeightLineChartView.swift**: UI for the weight line chart.
    - **WeightBarChartView.swift**: UI for the weight bar chart.
    - **ErrorHandlingView.swift**: Manages error handling UI.
  - **ViewModels/**: Contains view models for data management.
    - **HealthDataViewModel.swift**: Manages health data logic.
  - **Services/**: Contains services for external interactions.
    - **HealthKitService.swift**: Interacts with HealthKit.
  - **Utils/**: Contains utility extensions.
    - **Extensions.swift**: Common functionalities.
  - **Resources/**: Contains image assets and other resources.

- **HealthApp.xcodeproj**: Xcode project file.
- **HealthAppTests/**: Contains unit tests.
  - **HealthDataTests.swift**: Unit tests for health data functionalities.
- **HealthAppUITests/**: Contains UI tests.
  - **HealthDataUITests.swift**: UI tests for the application.
- **README.md**: Documentation for the project.


## Getting Started
To get started with this project, clone the repository and open the `HealthApp.xcodeproj` file in Xcode. Ensure you have the necessary permissions set up for HealthKit in your app's capabilities.

## Features
- Interactive charts for steps and weight.
- Health data visualization.
- Error handling and user feedback mechanisms.

## Contributing
Contributions are welcome! Please submit a pull request for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.