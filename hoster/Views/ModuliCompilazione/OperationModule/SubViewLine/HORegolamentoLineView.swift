//
//  HORegolamentoLineView.swift
//  hoster
//
//  Created by Calogero Friscia on 13/05/24.
//

import SwiftUI
import MyPackView

struct HORegolamentoLineView:View {
    
    @Binding var operation:HOOperationUnit
        
    var body: some View {
    
        VStack(alignment: .leading,spacing:3){
            
            CSLabel_conVB(
                placeHolder: "Data Regolamento",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "calendar",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) {
                    
                    HStack {
                        
                        DatePicker("", selection: $operation.regolamento, displayedComponents: .date)
                            .colorMultiply(Color.hoDefaultText)
                        Spacer()
                    }
                    
            }
            
            let imputDescribe = csTimeFormatter(style: .medium).data.string(from: operation.regolamento)
            
            Text("L'operazione è contabilizzata in data \(imputDescribe)")
                .italic()
                .font(.caption)
                .foregroundStyle(Color.malibu_p53)
            
        } // chiusa vstack

    } // chiusa body
}
