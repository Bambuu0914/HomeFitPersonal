import SwiftUI
import Charts

@main
struct HomeFit: App {
    var body: some Scene {
        WindowGroup { WorkoutView() }
    }
}

struct WorkoutView: View {
    @AppStorage("completedThrough") private var completedThrough = 0
    @State private var reviewDay: Int?
    @State private var showingDays = false

    private var day: Int { reviewDay ?? min(completedThrough + 1, 365) }

    var body: some View {
        TabView {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("HomeFit Personal 365", systemImage: "house.fill")
                            .font(.headline).foregroundStyle(.mint)
                        Text("\(day)-р өдөр").font(.largeTitle.bold())
                        ProgressView(value: Double(completedThrough), total: 365)
                        Text("\(completedThrough) / 365 өдөр дууссан")
                            .font(.subheadline).foregroundStyle(.secondary)
                        ForEach(WorkoutPlan.lines(for: day), id: \.self) { line in
                            if let guide = MovementGuide.all[line] {
                                MovementCard(title: line, guide: guide)
                            } else {
                                Text(line).frame(maxWidth: .infinity, alignment: .leading)
                                    .padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }.padding()
                }
                .safeAreaInset(edge: .bottom) {
                    if day == completedThrough + 1 {
                        Button {
                            completedThrough = day
                            reviewDay = nil
                        } label: {
                            Label("Өдрийг дуусгах", systemImage: "checkmark.circle")
                                .frame(maxWidth: .infinity).padding(.vertical, 6)
                        }
                        .buttonStyle(.borderedProminent).tint(.teal)
                        .padding(.horizontal).padding(.vertical, 8)
                        .background(.regularMaterial)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button { showingDays = true } label: {
                            Label("Өдөр сонгох", systemImage: "calendar")
                        }
                    }
                }
                .sheet(isPresented: $showingDays) {
                    NavigationStack {
                        List {
                            Button("Дараагийн төлөвлөсөн өдөр") {
                                reviewDay = nil
                                showingDays = false
                            }
                            ForEach(1...365, id: \.self) { number in
                                Button {
                                    reviewDay = number
                                    showingDays = false
                                } label: {
                                    HStack {
                                        Text("\(number)-р өдөр")
                                        Spacer()
                                        if number <= completedThrough {
                                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.teal)
                                        }
                                    }
                                }
                            }
                        }
                        .navigationTitle("Өдөр сонгох")
                        .toolbar { Button("Хаах") { showingDays = false } }
                    }
                }
            }
            .tabItem { Label("Дасгал", systemImage: "figure.strengthtraining.traditional") }

            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("\(completedThrough) / 365").font(.largeTitle.bold())
                        Text("Дууссан өдөр").foregroundStyle(.secondary)
                        Chart {
                            ForEach(0..<7, id: \.self) { index in
                                let start = [0, 28, 56, 91, 182, 273, 357][index]
                                let end = [28, 56, 91, 182, 273, 357, 365][index]
                                BarMark(
                                    x: .value("Шат", "\(index + 1)"),
                                    y: .value("Төлөвлөсөн", end - start)
                                ).foregroundStyle(Color.secondary.opacity(0.16)).position(by: .value("Бүлэг", "Нийт"))
                                BarMark(
                                    x: .value("Шат", "\(index + 1)"),
                                    y: .value("Дууссан", max(0, min(completedThrough, end) - start))
                                ).foregroundStyle(Color.teal).position(by: .value("Бүлэг", "Дууссан"))
                            }
                        }
                        .frame(height: 245)
                        .chartXAxisLabel("Хөтөлбөрийн шат")
                        .accessibilityLabel("Шат бүрийн төлөвлөсөн болон дууссан өдрийн график")
                        Label("Дууссан", systemImage: "circle.fill").foregroundStyle(.teal)
                        Label("Төлөвлөсөн", systemImage: "circle.fill").foregroundStyle(.secondary)
                    }.padding()
                }.navigationTitle("Миний явц")
            }
            .tabItem { Label("Явц", systemImage: "chart.bar.xaxis") }
        }
        .tint(.teal)
    }
}

struct MovementGuide {
    let instruction: String
    let start: [CGPoint]
    let finish: [CGPoint]

    init(_ instruction: String, _ start: [Int], _ finish: [Int]) {
        self.instruction = instruction
        self.start = Self.points(start)
        self.finish = Self.points(finish)
    }

    private static func points(_ coordinates: [Int]) -> [CGPoint] {
        stride(from: 0, to: coordinates.count, by: 2).map {
            CGPoint(x: Double(coordinates[$0]), y: Double(coordinates[$0 + 1]))
        }
    }

    // Head, shoulder, hip, elbow, wrist, knee and ankle in a 100×100 view.
    static let all: [String: MovementGuide] = [
        "Сандалд сууж босох": .init("Тогтвортой сандалд аажуухан суу. Хөлөө бүтнээр нь газарт тулж бос.",
            [43,25, 41,39, 30,66, 56,47, 70,51, 58,66, 62,90],
            [45,16, 45,30, 45,56, 56,40, 68,48, 46,73, 48,91]),
        "Хэвтээд ташаагаа өргөх": .init("Өвдгөө нугалж, хөлөө шалан дээр тавь. Өсгийгөөрөө түлхэж ташаагаа өргөөд аажуухан буулга.",
            [17,76, 29,82, 56,84, 41,88, 53,88, 73,57, 87,85],
            [17,76, 29,82, 56,63, 41,88, 53,88, 73,54, 87,85]),
        "Өсгий өргөх": .init("Хананд зөөлөн тул. Хоёр өсгийгөө зэрэг өргөөд хяналттай буулга.",
            [42,18, 42,32, 42,56, 60,39, 80,38, 43,73, 44,91],
            [43,10, 43,24, 43,49, 62,33, 80,38, 45,67, 51,83]),
        "Хананд тулж суниах": .init("Алгаа мөрний өндөрт хананд тавь. Биеэ шулуун байлгаад тохойгоо нугалж хананд ойрт. Дараа нь түлхэж буц.",
            [43,19, 40,30, 34,55, 59,35, 81,38, 26,73, 22,91],
            [62,22, 59,34, 46,55, 65,51, 81,38, 33,73, 22,91]),
        "Хананд нуруугаа нааж гараа дээш доош гулсуулах": .init("Нуруугаа хананд зөөлөн тул. Тохойгоо нугалсан байрлалаас гараа өвдөлтгүй хэмжээнд дээш гулсуул.",
            [51,22, 51,36, 51,63, 73,47, 73,29, 51,77, 51,92],
            [51,22, 51,36, 51,63, 66,24, 72,10, 51,77, 51,92]),
        "Хэвтээд өвдгөө ээлжлэн өргөх": .init("Нуруугаараа хэвтээд өвдгөө нугал. Нуруугаа хөдөлгөхгүйгээр нэг өвдгөө ташааныхаа дээр өргөөд буулга. Талаа соль.",
            [17,76, 29,83, 55,84, 42,88, 53,88, 72,57, 86,85],
            [17,76, 29,83, 55,84, 42,88, 53,88, 55,53, 76,53]),
        "Дөрвөн хөллөж эсрэг гар, хөлөө ээлжлэн сунгах": .init("Алгаа мөрний доор, өвдгөө ташааны доор тавь. Эсрэг гар, хөлөө сунгахдаа ташаагаа эргүүлэхгүй барь. Талаа соль.",
            [78,45, 64,51, 34,53, 65,70, 65,89, 33,84, 17,89],
            [78,45, 64,51, 34,53, 81,51, 95,51, 20,53, 7,54])
    ]
}

struct MovementCard: View {
    let title: String
    let guide: MovementGuide

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            HStack(spacing: 10) {
                pose(guide.start, label: "Эхлэх")
                pose(guide.finish, label: "Хөдөлгөөн")
            }
            .accessibilityHidden(true)
            Text(guide.instruction).font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private func pose(_ joints: [CGPoint], label: String) -> some View {
        VStack(spacing: 4) {
            Canvas { context, size in
                let scale = min(size.width, size.height) / 100
                let offset = (size.width - 100 * scale) / 2
                let points = joints.map { CGPoint(x: $0.x * scale + offset, y: $0.y * scale) }
                let segments = [(1, 2), (1, 3), (3, 4), (2, 5), (5, 6)]
                var limbs = Path()
                for (start, end) in segments {
                    limbs.move(to: points[start])
                    limbs.addLine(to: points[end])
                }
                context.stroke(limbs, with: .color(.teal), style: StrokeStyle(lineWidth: 5 * scale, lineCap: .round))
                let head = CGRect(x: points[0].x - 7 * scale, y: points[0].y - 7 * scale, width: 14 * scale, height: 14 * scale)
                context.fill(Path(ellipseIn: head), with: .color(.teal))
            }
            .frame(height: 95)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(6)
        .background(Color.teal.opacity(0.09), in: RoundedRectangle(cornerRadius: 12))
    }
}

enum WorkoutPlan {
    static func lines(for day: Int) -> [String] {
        if day == 365 {
            return [
                "15 минут тайван алх.",
                "Эхний долоо хоногтой харьцуулахад аль хөдөлгөөн хялбар болсныг тэмдэглэ."
            ]
        }

        let week = (day - 1) / 7 + 1
        let strength: String
        let walk: String
        switch week {
        case 1...4: (strength, walk) = ("1 тойрог × 6–8 давталт", "10")
        case 5...8: (strength, walk) = ("2 тойрог × 6–8 давталт", "12–15")
        case 9...13: (strength, walk) = ("2 тойрог × 8–10 давталт", "15–20")
        case 14...26: (strength, walk) = ("2 тойрог × 10–12 давталт", "20–25")
        case 27...39: (strength, walk) = ("3 тойрог × 8–10 давталт", "25–30")
        case 40...51: (strength, walk) = ("3 тойрог × 10–12 давталт", "25–35")
        default: (strength, walk) = ("1–2 тойрог × 6–8 давталт", "15–20")
        }

        let exercises: [String]
        switch (day - 1) % 7 {
        case 0:
            exercises = ["Сандалд сууж босох", "Хэвтээд ташаагаа өргөх", "Өсгий өргөх"]
        case 2:
            exercises = ["Хананд тулж суниах", "Хананд нуруугаа нааж гараа дээш доош гулсуулах", "Хэвтээд өвдгөө ээлжлэн өргөх"]
        case 4:
            exercises = ["Сандалд сууж босох", "Хананд тулж суниах", "Дөрвөн хөллөж эсрэг гар, хөлөө ээлжлэн сунгах"]
        case 1, 5:
            return ["\(walk) минут ярьж чадахаар хэмнэлээр гадаа эсвэл гэртээ алх."]
        case 3:
            return ["5–10 минут зөөлөн хөдөл.", "Мөр, шагайгаа тойруул. Дөрвөн хөллөж нуруугаа зөөлөн хотойлгож, бөгтийлгө."]
        default:
            return ["Амралтын өдөр. Хүсвэл тайван алх."]
        }

        return ["3–5 минут байрандаа алхаж, мөр, ташаагаа хөдөлгө.", strength]
            + exercises
            + ["Тал сольдог хөдөлгөөнийг тал бүрд тоол. Тойрог хооронд 60–90 секунд амар.",
               "Дуусгаад 2–3 минут тайван алхаж амьсгалаа жигдрүүл.",
               "Хурц өвдөлт мэдрэгдвэл тухайн хөдөлгөөнийг зогсоо."]
    }
}
