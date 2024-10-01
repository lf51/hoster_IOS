//
//  CurrentYearView.swift
//  hoster
//
//  Created by Calogero Friscia on 27/09/24.
//
import SwiftUI

@ViewBuilder func vbCurrentYearView(viewModel:HOViewModel) -> some View {
    
    HStack(spacing:5) {
        
        Image(systemName: "calendar")
        Text("\(viewModel.yyFetchData.description)")
         
        }
        .font(.subheadline)
        .foregroundStyle(Color.hoDefaultText)
        .opacity(0.6)
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: 5.0)
                .fill(Color.hoBackGround.opacity(0.4))
        }

}
