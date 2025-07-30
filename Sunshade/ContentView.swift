import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var dashboardViewModel = DashboardViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(viewModel: dashboardViewModel)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "sun.max.fill" : "sun.max")
                    Text("Dashboard")
                }
                .tag(0)
            
            SafetyTimerView(dashboardViewModel: dashboardViewModel)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "timer.circle.fill" : "timer.circle")
                    Text("Timer")
                }
                .tag(1)
            
            EducationView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "book.fill" : "book")
                    Text("Learn")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(AppColors.primary)
    }
}


// MARK: - Preview
#Preview {
    ContentView()
}
