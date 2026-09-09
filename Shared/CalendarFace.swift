import SwiftUI

struct CalendarFace: View {
    let countdown: Countdown
    var story = false
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black
                if countdown.isCommunityNight {
                    Image(story ? "CommunityNightStory" : "CommunityNightSquare")
                        .resizable().scaledToFit()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                } else if story && (0...21).contains(countdown.days) {
                    StoryFace(countdown: countdown)
                } else if (0...21).contains(countdown.days) {
                    Image(countdown.days == 0 ? "CardTODAY" : "Card\(countdown.days)")
                        .resizable().scaledToFit()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        (Text("OpenAI ").foregroundColor(.white) + Text("DevDay").foregroundColor(.blue))
                            .font(.system(size: proxy.size.width * 0.065))
                        Text("[2026]").foregroundStyle(.green).font(.system(size: proxy.size.width * 0.06))
                        Image(countdown.artwork).resizable().scaledToFit().frame(maxHeight: proxy.size.height * 0.4)
                        Text(countdown.headline).font(.system(size: proxy.size.width * 0.16))
                        Text(countdown.caption).font(.system(size: proxy.size.width * 0.045))
                    }.padding(proxy.size.width * 0.07).foregroundStyle(.white)
                }
            }
        }
        .accessibilityElement(children: .ignore).accessibilityLabel(countdown.accessibilityLabel)
    }
}

/// Independent layers use the full portrait canvas; no letterboxed square.
private struct StoryFace: View {
    let countdown: Countdown
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            Image("StoryHeader").resizable().scaledToFit()
                .frame(width: w * 0.87, height: h * 0.16, alignment: .topLeading)
                .position(x: w * 0.5, y: h * 0.21)
            Image(countdown.artwork).resizable().scaledToFit()
                .frame(width: w * 0.88, height: h * 0.28)
                .position(x: w * 0.5, y: h * 0.44)
            Image(countdown.days == 0 ? "NumberTODAY" : "Number\(countdown.days)").resizable().scaledToFit()
                .frame(width: w * (countdown.days == 0 ? 0.86 : 0.38), height: h * 0.15)
                .position(x: w * (countdown.days == 0 ? 0.5 : 0.72), y: h * 0.66)
            if countdown.days > 0 {
                Image(countdown.days == 1 ? "StoryDay" : "StoryDays").resizable().scaledToFit()
                    .frame(width: w * 0.42, height: h * 0.04)
                    .position(x: w * 0.72, y: h * 0.77)
            }
            Image("StoryFooter").resizable().scaledToFit()
                .frame(width: w * 0.8, height: h * 0.035, alignment: .leading)
                .position(x: w * 0.5, y: h * 0.815)
            Text("@OpenAIDevs").font(.system(size: w * 0.035, weight: .medium)).foregroundStyle(.white)
                .position(x: w * 0.5, y: h * 0.86)
        }
    }
}
