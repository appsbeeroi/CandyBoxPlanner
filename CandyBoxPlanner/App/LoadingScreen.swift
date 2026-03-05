import SwiftUI
import Foundation

struct LoadingScreen: View {
    @State private var showSplash = true
    @State private var isWebViewNeeded: Bool = false
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                if isWebViewNeeded {
                    
                } else {
                    HomeView()
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { showSplash = false }
            }
        }
    }
}
