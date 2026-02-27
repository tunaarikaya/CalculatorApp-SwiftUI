import SwiftUI

enum CalculatorButton: String {
    case one = "1", two = "2", three = "3", four = "4", five = "5"
    case six = "6", seven = "7", eight = "8", nine = "9", zero = "0"
    case add = "+", subtract = "-", multiply = "×", divide = "÷", equal = "="
    case clear = "AC", negative = "+/-", percent = "%", decimal = "."
    
    var buttonGradient: LinearGradient {
        switch self {
        case .add, .subtract, .multiply, .divide, .equal:
            return LinearGradient(gradient: Gradient(colors: [.orange, .yellow.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case .clear, .negative, .percent:
            return LinearGradient(gradient: Gradient(colors: [Color(.lightGray), Color(.gray)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    var textColor: Color {
        switch self {
        case .clear, .negative, .percent:
            return .black
        default:
            return .white
        }
    }
}

enum Operation {
    case add, subtract, multiply, divide, none
}

class CalculatorViewModel: ObservableObject {
    @Published var display = "0"
    @Published var runningNumber = 0.0
    @Published var currentOperation: Operation = .none
    
    private var isTyping = false
    
    func receiveInput(button: CalculatorButton) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            switch button {
            case .add, .subtract, .multiply, .divide:
                handleOperation(button)
            case .equal:
                performCalculation()
            case .clear:
                clear()
            case .negative:
                toggleNegative()
            case .percent:
                applyPercentage()
            case .decimal:
                addDecimal()
            default:
                appendNumber(button.rawValue)
            }
        }
    }
    
    private func appendNumber(_ number: String) {
        if isTyping {
            if display == "0" {
                display = number
            } else {
                display += number
            }
        } else {
            display = number
            isTyping = true
        }
    }
    
    private func addDecimal() {
        if !display.contains(".") {
            display += "."
            isTyping = true
        }
    }
    
    private func handleOperation(_ button: CalculatorButton) {
        if isTyping {
            performCalculation()
        }
        
        runningNumber = Double(display) ?? 0
        isTyping = false
        
        switch button {
        case .add: currentOperation = .add
        case .subtract: currentOperation = .subtract
        case .multiply: currentOperation = .multiply
        case .divide: currentOperation = .divide
        default: break
        }
    }
    
    private func performCalculation() {
        let currentValue = Double(display) ?? 0
        var result = 0.0
        
        switch currentOperation {
        case .add: result = runningNumber + currentValue
        case .subtract: result = runningNumber - currentValue
        case .multiply: result = runningNumber * currentValue
        case .divide: 
            if currentValue != 0 {
                result = runningNumber / currentValue
            } else {
                display = "Error"
                currentOperation = .none
                isTyping = false
                return
            }
        case .none: return
        }
        
        display = formatResult(result)
        runningNumber = result
        currentOperation = .none
        isTyping = false
    }
    
    private func toggleNegative() {
        if let value = Double(display) {
            display = formatResult(value * -1)
        }
    }
    
    private func applyPercentage() {
        if let value = Double(display) {
            display = formatResult(value / 100)
        }
    }
    
    private func clear() {
        display = "0"
        runningNumber = 0
        currentOperation = .none
        isTyping = false
    }
    
    private func formatResult(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return "\(value)"
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    
    let buttons: [[CalculatorButton]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equal]
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 12) {
                Spacer()
                
                // Display
                HStack {
                    Spacer()
                    Text(viewModel.display)
                        .font(.system(size: 85, weight: .light))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 24)
                }
                
                // Buttons
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            Button {
                                viewModel.receiveInput(button: button)
                            } label: {
                                Text(button.rawValue)
                                    .font(.system(size: 32, weight: .medium))
                                    .frame(width: buttonWidth(button: button), height: 80)
                                    .background(button.buttonGradient)
                                    .foregroundColor(button.textColor)
                                    .cornerRadius(40)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 24)
        }
    }
    
    private func buttonWidth(button: CalculatorButton) -> CGFloat {
        if button == .zero {
            return (UIScreen.main.bounds.width - 5 * 12) / 2 + 12
        }
        return (UIScreen.main.bounds.width - 5 * 12) / 4
    }
}

#Preview {
    ContentView()
}
