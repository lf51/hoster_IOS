//
//  ImputationTest.swift
//  hoster
//
//  Created by Calogero Friscia on 29/03/24.
//

import SwiftUI

struct SampleRow: View {
    let id: Int

    var body: some View {
        Text("Row \(id)")
    }

    init(id: Int) {
        print("Loading row \(id)")
        self.id = id
    }
}

struct LazyContentView: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(1...100, id: \.self, content: SampleRow.init)
            }
        }
        .frame(height: 300)
    }
}

#Preview {
    LazyContentView()
}
