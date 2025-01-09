import SwiftUI

struct ErrorHandlingView: View {
    @Binding var errorMessage: String?
    
    var body: some View {
        VStack {
            if let message = errorMessage {
                Text(message)
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Text("No errors.")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            // Additional setup if needed
        }
    }
}

struct ErrorHandlingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ErrorHandlingView(errorMessage: .constant("Sample error message"))
                .previewDisplayName("With Error Message")
            
            ErrorHandlingView(errorMessage: .constant(nil))
                .previewDisplayName("Without Error Message")
        }
    }
}