//
//  HOTimeImputationLineView.swift
//  hoster
//
//  Created by Calogero Friscia on 15/05/24.
//

import SwiftUI
import MyTextFieldSinkPack
import MyPackView

struct HOTimeImputationLineView:View {
    
    @ObservedObject var builderVM:HONewOperationBuilderVM
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            CSLabel_conVB(
                placeHolder: "Periodo di Imputazione",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "calendar.badge.checkmark",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) { EmptyView() }
            
            if let anno = builderVM.operation.timeImputation?.anno {
                
                HStack {
                    
                    let range = builderVM.getYearRangeForStepper()
                    
                    CSSinkStepper_1(
                        initialValue: anno,
                        range: range,
                        label: "Anno",
                        labelText: Color.hoDefaultText,
                        labelBackground: Color.scooter_p53,
                        valueColor: Color.hoDefaultText,
                        numberWidth: 80) { _, new in
                       
                            let bottom = range.lowerBound - 1
                            
                            self.builderVM.updateTimeImputationValue(newValue: new, upFrom: bottom, to: \.anno)

                    }
                        .fixedSize()

                }
                
            }
                
                
            if let month = builderVM.operation.timeImputation?.mese {
                
                HStack {
                    
                    CSSinkStepper_1(
                        initialValue: month,
                        range: 1...12,
                        label: "Mese",
                        labelText: Color.hoDefaultText,
                        labelBackground: Color.blazeOrange_p53,
                        valueColor: Color.hoDefaultText,
                        numberWidth: 35) { _, new in
        
                            self.builderVM.updateTimeImputationValue(newValue: new, to: \.mese)
                        }
                        .fixedSize()
                    
                    Picker(selection: $builderVM.monthImputation) {
                        
                        ForEach(HOMonthImputation.allCases,id:\.self) { monthImput in
                            
                            
                            Text(monthImput.rawValue)
                                .tag(monthImput as HOMonthImputation?)
  
                        }
                        
                    } label: {
                        //
                    }

                    
                }
                
                
            }
            
            if let timeImputation = self.builderVM.operation.timeImputation,
                let coefficiente = timeImputation.cfcAmmortamentoString {
                
                HStack {
                    
                    Image(systemName: "square.stack.3d.down.right")
                        // .bold()
                         .imageScale(.medium)
                         .foregroundStyle(Color.malibu_p53)
        
                    Text(coefficiente)
                        .foregroundStyle(Color.hoDefaultText)
                        .opacity(0.6)
                    
                    Spacer()
                }
                .padding(.vertical,5)
                .padding(.leading,5)
                .background {
                        RoundedRectangle(cornerRadius: 5.0)
                        .foregroundStyle(Color.hoDefaultText)
                            .opacity(0.1)
                            .shadow(radius: 5)
                            
                    }
                .csLock(Color.gray, .trailing, .trailing, true)
                
                HStack {
                    
                    let quota = timeImputation.getQuotaAmmortamento(from: self.builderVM.operation.amount?.imponibile)
                    
                    Image(systemName: "square.stack.3d.down.right.fill")
                         .imageScale(.medium)
                         .foregroundStyle(Color.malibu_p53)
        
                    Text("Quota Ammortamento: \(quota)")
                        .foregroundStyle(Color.hoDefaultText)
                        .opacity(0.6)
                    
                    Spacer()
                }
                .padding(.vertical,5)
                .padding(.leading,5)
                .background {
                        RoundedRectangle(cornerRadius: 5.0)
                        .foregroundStyle(Color.hoDefaultText)
                            .opacity(0.1)
                            .shadow(radius: 5)
                            
                    }
                .csLock(Color.gray, .trailing, .trailing, true)
                
                
                if let imputationAccountAvaible = builderVM.imputationAccountAvaible {
                    
                    HOFilterPickerView(
                        property: $builderVM.imputationAccount,
                        nilImage: "cursorarrow.click.2",
                        nilPropertyLabel: "per attività",
                        allCases: imputationAccountAvaible)
                    
                }
                
            }

            let imputDescribe = self.describeImputation()
            
            Text(imputDescribe)
                .italic()
                .font(.caption)
                .foregroundStyle(Color.malibu_p53)
            
            
        } // chiusa vstack
        .onAppear{ builderVM.initTimeImputation() }

    } // chousa body
    
   
    
    private func describeImputation() -> String {
        
        guard let storedTimeImputation = self.builderVM.operation.timeImputation else {
    
            return "questo tipo di operazione non viene imputata"}
    
        let importo = self.builderVM.operation.amount?.imponibile
        
        let importoString = self.builderVM.operation.amount?.imponibileStringValue
        
        return storedTimeImputation.getImputationDescription(importo,stringValue: importoString)
        
    }
    
}


struct HOAmountLineView:View {
    
    @ObservedObject var builderVM:HONewOperationBuilderVM
    
    @State private var quantityStepIncrement:Int = 1
    @State private var amountCategory:HOAmountCategory = .piece
    @State private var syncedPriceValue:Double?
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            CSLabel_conVB(
                placeHolder: "Amount",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "calendar.badge.checkmark",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) {
                    
                    Picker(selection: $amountCategory) {
                        
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
                
                let currentPrice = self.builderVM.operation.amount?.pricePerUnitStringValue
                
                let setup = self.setAmountFromCategory()
                
                HStack {
                    
                    CSSyncTextField_4b(placeHolder: currentPrice ?? "0.0", showDelete: false, keyboardType: .numbersAndPunctuation) {
                        
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
                        
                    } syncroAction: { new in
                    
                        self.builderVM.updateAmountValue(from:new, to: setup.path)
                        self.syncedPriceValue = Double(new)
                    }
                    .csModifier(self.builderVM.lockPrice) { view in
                        view
                            .opacity(0.5)
                            .csLock(Color.gray, .trailing, .trailing, true, true)
                            //.disabled(true)
                    }
                    
                    vbVisualCheckAndRefresh()
                }
                
                Text(currentPrice ?? "prezzo medio di carico nullo")
                    .italic(currentPrice == nil)
                    .font(.callout)
                    .foregroundStyle(Color.malibu_p53)
                   // .opacity(maxAchieve ? 1.0 : 0.5)
                
                if let imponibile = self.builderVM.operation.amount?.imponibileStringValue {

                    Text("totale: \(imponibile)")
                        .font(.callout)
                        .foregroundStyle(Color.malibu_p53)
                    
                }
                
            }

        } // chiusa vstack madre
        .onAppear { self.builderVM.initOperationAmount() }
    } // chiusa body
    
    
    private func vbVisualCheckAndRefresh() -> some View {
        
         guard let syncedPriceValue,
               let currentAmount = self.builderVM.operation.amount,
               let pmc = currentAmount.pricePerUnit,
               let total = currentAmount.imponibile else {
          
             return Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                 Image(systemName: "checkmark.circle")
                       .foregroundStyle(Color.gray)
             }).disabled(true)
             
         }
             var currentValueToCheck:Double?
             
             switch amountCategory {
             case .piece:
                 currentValueToCheck = pmc
             case .pack:
                 currentValueToCheck = total
             }
             
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
                 let converted = Int(syncedPriceValue)
                 buttonAction = {self.builderVM.updateAmountValue(from: converted, to: path)}
                
                 
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
        
        let label = amountCategory.rawValue.capitalized
        var path:WritableKeyPath<HOOperationAmount,Double?>
        
        switch amountCategory {
        case .piece:
            path = \.pricePerUnit
        case .pack:
            path = \.imponibile
        }
        
        return (label,path)
    }
    
    
}


