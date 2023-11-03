//: A UIKit based Playground for presenting user interface
  
import SwiftUI
import PlaygroundSupport

struct ContentView: View {
    @ObservedObject private var model: SampleModel = .init()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8, content: {
            TopView(background: model.background)
            Divider()
            Form(content: {
                Section("Background Color") {
                    ColorConfigurationRowView(
                        colors: model.background.colors,
                        selectedColor: $model.selectedColor
                    )
                }
            })
            Spacer()
        })
    }
}

// MARK: - VIEWS
struct TopView: View {
    let background: SampleModel.BackgroundModel
    
    var body: some View {
        ZStack(alignment: .center, content: {
            BackgroundView(background: background)
            Text("Top View")
        })
    }
}

struct ColorConfigurationRowView: View {
    let colors: [ColorModel]
    @Binding public var selectedColor: ColorModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.fixed(40))],
                      alignment: .center,
                      spacing: 10) {
                ForEach(colors) { color in
                    ColorView(model: color,
                              isSelected: color == selectedColor)
                    .onTapGesture {
                        selectedColor = color
                    }
                }
            }
        }
    }
}

struct ColorView: View {
    let model: ColorModel
    var isSelected: Bool

    var body: some View {
        Circle()
            .fill(model.color)
            .frame(width: 50, height: 50)
            .overlay(
                Circle().stroke(Color.green,
                                lineWidth: isSelected ? 3 : 0)
                .padding(-5)
            )
    }
}

struct BackgroundView: View {
    let background: SampleModel.BackgroundModel
    
    var body: some View {
        if background.isColorType {
            LinearGradient(colors: colors,
                           startPoint: .leading,
                           endPoint: .trailing)
        }else {
            Text("Picture")
        }
    }
    
    private var colors: [Color] {
        background.colors.compactMap { $0.color }
    }
}

// MARK: - MODELS
// MARK: - Sample Model
class SampleModel: ObservableObject {
    @Published var background: BackgroundModel
    @Published var selectedColor: ColorModel
    
    init() {
        let colors  = ColorModel.randomColors
        
        background = .init(colors: colors)
        selectedColor = colors[0]
    }
}

// MARK: - Background Model
extension SampleModel {
    struct BackgroundModel: Codable {
        public let colors: [ColorModel]
        
        init(colors: [ColorModel] = []) {
            self.colors = colors
        }
        
        public var isColorType: Bool {
            return !colors.isEmpty
        }
    }
}

// MARK: - Color Model
struct ColorModel: Identifiable, Codable, Equatable {
    public var id: String
    public var name: String
    public var hexCode: String
    
    static let orange: ColorModel = .init(id: "orange", name: "Orange", hexCode: "FFA500")
    
    var color: Color {
        let colour = Color(hex: hexCode)
        return colour
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hexCode == rhs.hexCode
    }
    
    
    static let random: ColorModel = .init(id: "random", name: "Random", hexCode: Color.random.toHex() ?? "FFFFFF")
    static let randomColors: [ColorModel] = randomColors(count: 15)
    
    private static func randomColors(count: Int) -> [ColorModel] {
        var colors: [ColorModel] = []
        for index in 1...count {
            colors.append(randomColor(name: "Random \(index)"))
        }
        return colors
    }
    private static func randomColor(name: String) -> ColorModel {
        return .init(id: name.lowercased(), name: name, hexCode: Color.random.toHex() ?? "FFFFFF")
    }
}



// MARK: - EXTENSIONS
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor?.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
    
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
}

PlaygroundPage.current.setLiveView(ContentView().frame(width: 300, height: 500))
