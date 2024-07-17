//
//  HOCityTaxLineView.swift
//  hoster
//
//  Created by Calogero Friscia on 14/07/24.
//

import SwiftUI
import MyPackView
import MyTextFieldSinkPack

struct HOCityTaxLineView: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    @ObservedObject var builderVM:HONewReservationBuilderVM
   
    let focusEqualValue:HOReservation.FocusField?
    @FocusState.Binding var focusField:HOReservation.FocusField?
    
    var body: some View {
       
        VStack(alignment: .leading, spacing: 10) {
           
            let pernottamenti = self.builderVM.reservation.pernottamenti
            
            let isTaxApplied = self.builderVM.cityTax != 0
            
            CSLabel_conVB(
                placeHolder: "Pernottamenti (\(pernottamenti))",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "calendar",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) {

                    CS_ErrorMarkView(
                        warningColor: .yellow,
                        scale: .medium,
                        padding: (.trailing,0),
                        generalErrorCheck: true,
                        localErrorCondition:
                        !isTaxApplied)
                    
            }

            if isTaxApplied {
                
                let pernTassati = self.builderVM.pernottamentiTassati
                
                VStack(alignment:.leading,spacing:5) {
                    
                    HStack {
                        
                        CSSinkStepper_1(
                            initialValue: 0,
                            range: 0...pernottamenti,
                            step: 1,
                            label: "Esenzione",
                            labelText: Color.red,
                            labelBackground: Color.hoBackGround,
                            image: nil,
                            imageColor: nil,
                            valueColor: Color.hoAccent,
                            numberWidth: 75) { _, newValue in
                                self.builderVM.pernottamentiEsentiCityTax = newValue
                            }
                            .fixedSize()
                        
                        HStack {
                            
                            Text("tax:")
                                .bold()
                                .foregroundStyle(Color.white)
                            
                            HStack(spacing:2) {
                                
                                Text("\(pernTassati)")
                                    .foregroundStyle(Color.red)
                                Text("/")
                                    .foregroundStyle(Color.gray)
                                Text("\(pernottamenti)")
                                    .bold()
                                    .foregroundStyle(Color.white)
                                
                            }
                        }
                        
                    }
                    
                    vbCityTaxtBox()
                    
                }
                
            } else {
                
                Text("[vedi setup] tassa di soggiorno non applicabile")
                    .italic()
                    .font(.callout)
                    .foregroundStyle(Color.malibu_p53)
                
            }

        }
      
        
    } // chiusa body

    
    @ViewBuilder private func vbCityTaxtBox() -> some View {
        
        let value = Double(self.builderVM.pernottamentiTassati) * self.builderVM.cityTax
        
       HStack {
            
            Text("City Tax:")
                .fontDesign(.monospaced)
                .fontWeight(.semibold)
                .font(.subheadline)
                .foregroundStyle(Color.hoDefaultText)
                
           Text("\(value,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
               // .italic()
                .fontWeight(.bold)
                .font(.body)
                .foregroundStyle(Color.malibu_p53)
               // .lineLimit(1)
         //  Spacer()
        }
       
        .padding(.horizontal,10)
        .padding(.vertical,5)
        .background {
            
            RoundedRectangle(cornerRadius: 10.0)
                .foregroundStyle(Color.hoBackGround)
               // .frame(maxWidth:.infinity)
               
        }
        
    }
    
    
    
}

/*#Preview {
    HOCityTaxLineView()
}*/
