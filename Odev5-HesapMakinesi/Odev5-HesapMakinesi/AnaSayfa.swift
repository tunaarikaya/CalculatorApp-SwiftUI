import SwiftUI

struct ContentView: View {
    @State private var displayText = "0"
    @State private var currentInput = ""
    @State private var storedValue: Double? = 0.0
    @State private var currentOperator: String?
    
    var body: some View {
        VStack {
            Text(displayText)
                .font(.system(size: 70))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            
            //zkkx
            CalculatorButtonRow(buttons: ["7", "8", "9", "+"], action: buttonTap)
            CalculatorButtonRow(buttons: ["4", "5", "6", "-"], action: buttonTap)
            CalculatorButtonRow(buttons: ["1", "2", "3", "*"], action: buttonTap)
            CalculatorButtonRow(buttons: ["0", ".", "=", "/"], action: buttonTap)
            CalculatorButtonRow(buttons: ["C"], action: {button in clearButton() })
        }
        .padding()
    }
    
    
    func clearButton(){
        currentInput = ""
        storedValue = nil
        currentInput = ""
        displayText = "0"
    }
    
    
    func buttonTap(_ button: String) {
        switch button {
        case "+", "-", "*", "/":
            currentOperator = button
            storedValue = Double(currentInput)
            currentInput = ""
        case "=":
            if let operatorType = currentOperator,
               let storedValue = storedValue,
               let currentValue = Double(currentInput) {
                let result: Double
                switch operatorType {
                case "+":
                    result = storedValue + currentValue
                case "-":
                    result = storedValue - currentValue
                case "*":
                    result = storedValue * currentValue
                case "/":
                    result = storedValue / currentValue
                default:
                    fatalError("Unknown operator")
                }
                currentInput = "\(result)"
                currentOperator = nil
            }
        case ".":
            if !currentInput.contains(".") {
                currentInput += button
            }
        default:
            currentInput += button
        }
        displayText = currentInput
        
        if (currentInput.isEmpty) {
            displayText = "0"
        }else{
            displayText = currentInput
        }
    }
   
}

struct CalculatorButtonRow: View {
    let buttons: [String]
    let action: (String) -> Void
    let buttonSize = (UIScreen.main.bounds.width - 5 * 12) / 4
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(buttons, id: \.self) { buttonLabel in
                Button {
                    action(buttonLabel)
                } label: {
                    Text(buttonLabel)
                        .font(.title)
                        .frame(width: buttonSize, height: buttonSize)
                        .background(Color.orange)
                        .foregroundStyle(.black)
                        .cornerRadius(buttonSize / 2)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
