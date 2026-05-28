import SwiftUI

extension View {
    func dismissKeyboard() -> some View {
        self.onTapGesture {
            #if canImport(UIKit)
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
            #endif
        }
    }

    func sectionTitle() -> some View {
        self
            .font(.appCaption2)
            .foregroundStyle(Color.appTextSecondary)
            .tracking(0.8)
            .textCase(.uppercase)
    }

    func staggeredAppear(index: Int, appeared: Bool) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(
                .spring(response: 0.4, dampingFraction: 0.8)
                    .delay(Double(index) * 0.08),
                value: appeared
            )
    }
}
