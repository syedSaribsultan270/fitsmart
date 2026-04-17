// FitSmartWidget.swift
//
// iOS WidgetKit extension for FitSmart.
// Reads data written by Flutter HomeWidgetService via shared UserDefaults
// in the App Group "group.com.fitsmart.widget".
//
// Setup required in Xcode:
//   1. File → New → Target → Widget Extension → name: FitSmartWidget
//   2. In the widget target: Signing & Capabilities → + App Groups → group.com.fitsmart.widget
//   3. In the Runner target: Signing & Capabilities → + App Groups → group.com.fitsmart.widget
//   4. Replace the generated FitSmartWidget.swift with this file.
//
// The home_widget Flutter package will then call reloadAllTimelines() to
// refresh the widget whenever HomeWidgetService.update() is called.

import WidgetKit
import SwiftUI

private let appGroup = "group.com.fitsmart.widget"

// MARK: - Timeline Entry

struct FitSmartEntry: TimelineEntry {
    let date: Date
    let caloriesRemaining: Int
    let caloriesGoal: Int
    let caloriesPct: Int
    let streakDays: Int
    let updatedAt: String
}

// MARK: - Provider

struct Provider: TimelineProvider {
    private func readDefaults() -> FitSmartEntry {
        let defaults = UserDefaults(suiteName: appGroup)
        let remaining = defaults?.integer(forKey: "calories_remaining") ?? 0
        let goal      = defaults?.integer(forKey: "calories_goal")      ?? 2000
        let pct       = defaults?.integer(forKey: "calories_pct")       ?? 0
        let streak    = defaults?.integer(forKey: "streak_days")        ?? 0
        let updated   = defaults?.string(forKey: "updated_at")          ?? "--"
        return FitSmartEntry(
            date: .now,
            caloriesRemaining: remaining,
            caloriesGoal: goal,
            caloriesPct: pct,
            streakDays: streak,
            updatedAt: updated
        )
    }

    func placeholder(in context: Context) -> FitSmartEntry {
        FitSmartEntry(date: .now, caloriesRemaining: 1240, caloriesGoal: 2000,
                      caloriesPct: 38, streakDays: 3, updatedAt: "--")
    }

    func getSnapshot(in context: Context, completion: @escaping (FitSmartEntry) -> Void) {
        completion(readDefaults())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FitSmartEntry>) -> Void) {
        let entry = readDefaults()
        // Refresh every 30 minutes (Flutter also calls reloadAllTimelines on data change)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Widget View

struct FitSmartWidgetView: View {
    let entry: FitSmartEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallView(entry: entry)
        default:
            SmallView(entry: entry)
        }
    }
}

struct SmallView: View {
    let entry: FitSmartEntry
    private let lime = Color(red: 0.741, green: 1.0, blue: 0.227)

    var body: some View {
        ZStack {
            Color(red: 0.067, green: 0.067, blue: 0.071)
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: CGFloat(entry.caloriesPct) / 100)
                        .stroke(lime, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 0) {
                        Text("\(entry.caloriesRemaining)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(lime)
                        Text("kcal left")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 60, height: 60)
                Text(entry.streakDays > 0 ? "\(entry.streakDays)d streak 🔥" : "Start streak!")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(10)
        }
    }
}

// MARK: - Widget Config

@main
struct FitSmartWidgetBundle: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "FitSmartWidget", provider: Provider()) { entry in
            FitSmartWidgetView(entry: entry)
        }
        .configurationDisplayName("FitSmart")
        .description("Today's calories remaining and streak.")
        .supportedFamilies([.systemSmall])
    }
}
