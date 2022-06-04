//
//  SlideBannerView.swift
//  SlideBanner
//
//  Created by hoseung Lee on 2022/06/04.
//

import SwiftUI

struct SlideBannerView<Content: View>: View {

  enum Direction {
    case forward
    case backward
  }

  @State var halfDown: Bool = false
  @State var xOffset: CGFloat = 0
  @State var xWeight: CGFloat = 0
  @State var currentPage = 0
  @State var offsets: [CGFloat] = []
  let totalPage: Int
  var content: () -> Content

  var body: some View {
    ZStack {
      GeometryReader { proxy in
        VStack(alignment: .leading, spacing: 0) {
          HStack(spacing: 0) {
            content()
              .frame(width: proxy.size.width)
          }
          .offset(x: xOffset)
          .gesture(drag(geometry: proxy))
        }
        .onAppear {
          offsets = (0..<totalPage).map { -(CGFloat($0) * proxy.size.width)}
        }
      }
      VStack {
        Text("\(currentPage)")
      }
    }
  }

  init(totalPage: Int, @ViewBuilder content: @escaping () -> Content) {
    self.totalPage = totalPage
    self.content = content
  }

  private func drag(geometry: GeometryProxy) -> some Gesture {
    DragGesture()
      .onChanged({ moved in
        xOffset = moved.translation.width + xWeight
      })
      .onEnded({ moved in

        let halfDown = caculateHalfline(geomtry: geometry, endMoved: moved.translation.width)
        let direction = dragDirection(endMoved: moved.translation.width)
        let nextPage = getNextPage(halfDown: halfDown, direction: direction)

        currentPage = nextPage
        withAnimation {
          xOffset = offsets[nextPage]
        }
        xWeight = xOffset
      })
  }

  private func getNextPage(halfDown: Bool, direction: Direction) -> Int {
    var nextPage = halfDown ? currentPage : direction == .forward ? currentPage + 1 : currentPage - 1

    nextPage = nextPage >= totalPage ? nextPage - 1 : nextPage
    nextPage = nextPage < 0 ? 0 : nextPage

    return nextPage
  }

  private func dragDirection(endMoved: CGFloat) -> Direction {
    endMoved >= 0 ? .backward : .forward
  }

  private func setScrollPosition(geometry: GeometryProxy, halfDown: Bool, direction: Direction) -> CGFloat {
    let unit = geometry.size.width
    if halfDown {
      return 0
    } else {
      return direction == .forward ? -unit : unit
    }
  }

  private func caculateHalfline(geomtry: GeometryProxy, endMoved: CGFloat) -> Bool {
    let unit = geomtry.size.width / 2
    let halfDown = abs(endMoved) < unit
    self.halfDown = halfDown
    return halfDown
  }
}
