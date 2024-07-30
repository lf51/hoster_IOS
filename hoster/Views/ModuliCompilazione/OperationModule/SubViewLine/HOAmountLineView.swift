//
//  HOAmountLineView.swift
//  hoster
//
//  Created by Calogero Friscia on 03/07/24.
//

import SwiftUI
import MyPackView
import MyTextFieldSinkPack

struct HOAmountLineView:View {
    
    @ObservedObject var builderVM:HONewOperationBuilderVM
    let generalErrorCheck:Bool
    
    @State private var quantityStepIncrement:Int = 1
   // @State private var amountCategory:HOAmountCategory = .piece
   // @State private var syncedPriceValue:String?
    
    let focusEqualValue:HOOperationUnit.FocusField?
    @FocusState.Binding var focusField:HOOperationUnit.FocusField?
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            CSLabel_conVB(
                placeHolder: "Amount",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "calendar.badge.checkmark",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) {
                    
                    Picker(selection: $builderVM.amountCategory) {
                        
                        ForEach(HOAmountCategory.allCases,id:\.self) { category in
                            
                            Text(category.rawValue)

                        }

                    } label: {
                        //
                    }
                    .menuIndicator(.hidden)
                    .disabled(self.builderVM.lockPrice)
                    .tint(Color.hoAccent)
                    
                }

            VStack(alignment:.leading,spacing: 5) {
                
                let value = builderVM.getRangeQuantity()
                let unitMisure = self.builderVM.operation.quantityAmountMisureUnit
         
                HStack {

                    CSSinkStepper_1(
                        initialValue: nil,
                        range: value.range,
                        step: quantityStepIncrement,
                        label: unitMisure.getExtendedRawValue().capitalized,
                        labelText: Color.hoDefaultText,
                        labelBackground: Color.scooter_p53,
                        valueColor: Color.hoDefaultText,
                        numberWidth: 80) { _, new in

                            self.builderVM.updateAmountValue(from: new, to: \.quantity)

                    }
                        .fixedSize()
                        
                    Button {
                        
                        self.setIncrement()
                        
                    } label: {
                        
                        Text("+ \(self.quantityStepIncrement)")
                            .bold()
                            .font(.callout)
                            .foregroundStyle(Color.hoAccent)
                    }.buttonBorderShape(.roundedRectangle)

                }
                
                if value.isLocked {
                    
                    let maxAchieve = self.builderVM.operation.quantityAmountAchieve ?? false
                    
                    let maxQ = self.builderVM.operation.writing?.oggetto?.partialAmount?.quantityStringValue ?? ""
                    
                    let unitRawValue = unitMisure.rawValue
                    
                    Text("max: [\(unitRawValue) \(maxQ)]")
                        .italic()
                        .font(.caption)
                        .foregroundStyle(Color.malibu_p53)
                        .opacity(maxAchieve ? 1.0 : 0.5)
                       
                    
                }
                
            }
            
            VStack(alignment:.leading,spacing: 5) {
                
               // let currentPrice = self.builderVM.operation.amount?.pricePerUnitStringValue
                let currentPrice = self.builderVM.sharedAmount?.pricePerUnitStringValue
                let placeHolder = String(self.builderVM.sharedAmount?.pricePerUnit ?? 0.0)
                let setup = self.setAmountFromCategory()
                
                HStack {
                    
                    CSSyncTextField_4b(placeHolder: placeHolder, showDelete: false, keyboardType:.decimalPad,focusValue: focusEqualValue,focusField: $focusField) {
                        
                        HStack(spacing:5) {
                            
                            Text(setup.label)
                                .foregroundStyle(.white)
                                .bold()
                                .padding(.vertical,10)
                                .padding(.horizontal,6)
                                .background(Color.blazeOrange_p53.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 10,style: .continuous))
                            
                            Image(systemName: "eurosign.circle.fill")
                                .imageScale(.large)
                                .bold()
                                .foregroundStyle(currentPrice == nil ? Color.gray : Color.green)
                        }
                        
                    } disableLogic: { value in
                        
                        let converted = csConvertToDotDouble(from: value)
                        return converted == 0.0
                        
                    } syncroAction: { new in
                    
                        self.builderVM.updateAmountValue(from:new, to: setup.path)
                        let converted = csConvertToDotDouble(from: new)
                        self.builderVM.syncedPriceValue = String(converted)
                    }
                    .csModifier(self.builderVM.lockPrice) { view in
                        view
                            .opacity(0.5)
                            .csLock(Color.gray, .trailing, .trailing, true, true)
                            //.disabled(true)
                    }
                    
                    vbVisualCheckAndRefresh()
                }
                
                Text(currentPrice ?? "prezzo unitario nullo")
                    .italic(currentPrice == nil)
                    .font(.callout)
                    .foregroundStyle(Color.malibu_p53)
                   // .opacity(maxAchieve ? 1.0 : 0.5)
                
               /* if let imponibile = self.builderVM.operation.amount?.imponibileStringValue {

                    Text("totale: \(imponibile)")
                        .font(.callout)
                        .foregroundStyle(Color.malibu_p53)
                    
                }*/
                
                if let imponibile = self.builderVM.sharedAmount?.imponibileStringValue {

                    Text("totale: \(imponibile)")
                        .font(.callout)
                        .foregroundStyle(Color.malibu_p53)
                    
                }
                
            }

        } // chiusa vstack madre
        .onAppear { self.builderVM.initOperationAmount() }
    } // chiusa body
    
    
    private func vbVisualCheckAndRefresh() -> some View {
        
         guard let syncedPriceValue = builderVM.syncedPriceValue,
               let currentValueToCheck = builderVM.currentValueToCheck,
              // let currentAmount = self.builderVM.operation.amount,
               let currentAmount = self.builderVM.sharedAmount,
               let _ = currentAmount.pricePerUnit,
               let _ = currentAmount.imponibile else {
          
             let value:(image:String,color:Color) = {
                 
                 if self.generalErrorCheck {
                     return ("exclamationmark.triangle.fill",Color.hoWarning)
                     
                 } else {
                     return ("checkmark.circle",Color.gray)
                 }
             }()
             
             return Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                 Image(systemName: value.image)
                     .foregroundStyle(value.color)
             }).disabled(true)
             
         }
            /* var currentValueToCheck:String?
             
             switch amountCategory {
             case .piece:
                 currentValueToCheck = String(pmc)
             case .pack:
                 currentValueToCheck = String(total)
             }*/
             
        var buttonImageName:String
        var buttonColor:Color
        var buttonAction:() -> () = { }
        var buttonDisable:Bool
        
             if currentValueToCheck == syncedPriceValue {
                 
                 buttonImageName = "checkmark.circle.fill"
                 buttonColor = Color.malibu_p53
                 buttonDisable = true
                
             } else {
                 
                 buttonImageName = "arrow.clockwise.circle.fill"
                 buttonColor = Color.hoAccent
                 buttonDisable = false
                 
                 let path = self.setAmountFromCategory().path
                // let converted = Int(syncedPriceValue)
                 buttonAction = {self.builderVM.updateAmountValue(from: syncedPriceValue, to: path)}
                
                 
             }
        
        return Button(action: {
            
            buttonAction()
            
        }, label: {
            Image(systemName: buttonImageName)
                 .foregroundStyle(buttonColor)
        })
        .disabled(buttonDisable)

         }
    
    private func setIncrement() {
        
        let current = self.quantityStepIncrement
        
        if current == 1 { self.quantityStepIncrement = 5 }
        
        else if current % 25 != 0 { self.quantityStepIncrement += 5}
        
        else { self.quantityStepIncrement = 1}
        
        
    }
    
    private func setAmountFromCategory() -> (label:String,path:WritableKeyPath<HOOperationAmount,Double?>) {
        
        let label = builderVM.amountCategory.rawValue.capitalized
        var path:WritableKeyPath<HOOperationAmount,Double?>
        
        switch builderVM.amountCategory {
        case .piece:
            path = \.pricePerUnit
        case .pack:
            path = \.imponibile
        }
        
        return (label,path)
    }
    
    
}
