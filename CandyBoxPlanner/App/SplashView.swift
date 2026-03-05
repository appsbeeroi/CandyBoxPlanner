import SwiftUI

struct SplashView: View {
    @State private var animate = false

    var body: some View {
        BgView {
            VStack {
                Spacer()
                Image(.load)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .scaleEffect(animate ? 1.10 : 0.9)
                    .opacity(animate ? 1 : 0.95)
                    .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: animate)
                    .onAppear { animate = true }
                Spacer()
            }
        }
    }
}
