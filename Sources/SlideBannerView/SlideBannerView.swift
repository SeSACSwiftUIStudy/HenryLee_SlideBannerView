//
//  SlideBannerView.swift
//  SlideBanner
//
//  Created by hoseung Lee on 2022/06/04.
//

import SwiftUI
import Combine

public struct SlideBannerView<Content: View>: View {

  enum Direction {
    case forward
    case backward
  }

  @State private var halfDown = false
  @State private var xOffset: CGFloat = 0
  @State private var xWeight: CGFloat = 0
  @State private var offsets: [CGFloat] = []
  @State private var totalPage: Int
  @State private var autoSlide = true
  @State private var indicatorText = ""
  @State private var showIndicator = true
  @State private var currentIndex = 0
  @Binding var selectedIndex: Int
  @State private var cancellables = Set<AnyCancellable>()
  var content: () -> Content

  public var body: some View {
    ZStack {
      GeometryReader { proxy in
        HStack(spacing: 0) {
          content()
            .frame(width: proxy.size.width)
        }
        .offset(x: xOffset)
        .gesture(drag(geometry: proxy))
        .onAppear {
          offsets = (0..<totalPage).map { -(CGFloat($0) * proxy.size.width) }
        }
      }
      VStack {
        Spacer()
        HStack {
          Spacer()
          indicator
            .padding()
        }
      }
    }
    .onAppear {
      if autoSlide {
        Timer
          .publish(every: 3, on: .main, in: .default)
          .sink { _ in
            pageUpdate(nextIndex: currentIndex + 1)

          }
          .store(in: &cancellables)
      }
    }
    .onAppear {
      pageUpdate(nextIndex: selectedIndex, animating: false)
    }
    .onChange(of: selectedIndex) { newValue in
      pageUpdate(nextIndex: newValue)
    }
    .onChange(of: currentIndex) { newValue in
      _selectedIndex.wrappedValue = newValue
    }

  }

  private func pageUpdate(nextIndex: Int, animating: Bool = true) {
    currentIndex = nextIndex % totalPage
    
    withAnimation(.easeInOut(duration: animating ? 0.3 : 0)) {
      xOffset = offsets[currentIndex]
    }
    xWeight = xOffset
  }

  @ViewBuilder
  var indicator: some View {
    if showIndicator {
      Text("\(currentIndex + 1) / \(totalPage)")
        .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
        .background(
          Capsule()
            .foregroundColor(.gray.opacity(0.7))
            .shadow(radius: 1)
        )
    } else {
      EmptyView()
    }
  }

  public init(totalPage: Int, autoSlide: Bool = false, selectedIndex: Binding<Int>, showIndicator: Bool = true, @ViewBuilder content: @escaping () -> Content) {
    self.totalPage = totalPage
    self.autoSlide = autoSlide
    self.showIndicator = showIndicator
    self.content = content
    self._selectedIndex = selectedIndex
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

        pageUpdate(nextIndex: nextPage)
      })
  }

  private func getNextPage(halfDown: Bool, direction: Direction) -> Int {
    var nextPage = halfDown ? currentIndex : direction == .forward ? currentIndex + 1 : currentIndex - 1

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
