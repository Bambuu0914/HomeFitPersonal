import SwiftUI

@main
struct HomeFit: App {
    var body: some Scene {
        WindowGroup { WorkoutView() }
    }
}

struct WorkoutView: View {
    @AppStorage("completedThrough") private var completedThrough = 0
    @State private var reviewDay: Int?

    private var day: Int { reviewDay ?? min(completedThrough + 1, 365) }

    var body: some View {
        NavigationStack {
            List {
                Section("Явц") {
                    ProgressView(value: Double(completedThrough), total: 365)
                    Text("\(completedThrough) / 365 өдөр дууссан")
                }
                Section("\(day)-р өдөр") {
                    ForEach(WorkoutPlan.lines(for: day), id: \.self) { line in
                        Text(line)
                    }
                    if day == completedThrough + 1 {
                        Button("Өдрийг дуусгах") {
                            completedThrough = day
                            reviewDay = nil
                        }
                    }
                }
                Section("Өдөр сонгох") {
                    Button("Дараагийн төлөвлөсөн өдөр") { reviewDay = nil }
                    Stepper(
                        "Харж буй өдөр · \(day)",
                        value: Binding(get: { day }, set: { reviewDay = $0 }),
                        in: 1...365
                    )
                }
            }
            .navigationTitle("HomeFit Personal 365")
        }
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
