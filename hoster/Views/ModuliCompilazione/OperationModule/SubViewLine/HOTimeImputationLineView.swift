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
    let generalErrorCheck:Bool
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {

            CSLabel_conVB(
                placeHolder: "Periodo di Imputazione",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "calendar.badge.checkmark",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) {

                    vbPickPeriods()
                    
                }

            if let firstYY = builderVM.sharedTimeImputation?.startYY {
                
                 HStack {
                     
                     let range = builderVM.getYearRangeForStepper()
                     
                     CSSinkStepper_1(
                         initialValue: firstYY,
                         range: range,
                         label: "Anno",
                         labelText: Color.hoDefaultText,
                         labelBackground: Color.scooter_p53,
                         valueColor: Color.hoDefaultText,
                         numberWidth: 80) { _, new in
                        
                             self.builderVM.updateTimeImputationYearValue(to: new)
                     }
                         .fixedSize()

                 }
 
             }
                
            if let monthImputation = builderVM.sharedTimeImputation?.monthImputation,
               let month = monthImputation.mmStart {
                
                let lockCondition = monthImputation.lockEditStartMM()
                
                 HStack {
                     
                     CSSinkStepper_1(
                         initialValue: month,
                         range: 1...12,
                         label: "Mese",
                         labelText: Color.hoDefaultText,
                         labelBackground: Color.blazeOrange_p53,
                         valueColor: Color.hoDefaultText,
                         numberWidth: 35) { _, new in
         
                             self.builderVM.updateTimeImputationMonthValue(to: new)
                         }
                         .fixedSize()
                     
                         Spacer()
                 }
                 .id(monthImputation.period)
                 .csLock(Color.gray, .trailing, .trailing, lockCondition, true)

             }

            if let sharedTimeImputation = builderVM.sharedTimeImputation,
               let coefficiente = sharedTimeImputation.cfcAmmortamentoString {
                
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
                    
                   // let quota = sharedTimeImputation.getQuotaAmmortamento(from: self.builderVM.operation.amount?.imponibile)
                    let quota = sharedTimeImputation.getQuotaAmmortamento(from: self.builderVM.sharedAmount?.imponibile)
                    
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
                
            }
            
            if let imputationAccountAvaible = builderVM.imputationAccountAvaible {
                
                HOFilterPickerView(
                    property: $builderVM.imputationAccountAssociated,
                    nilImage: "cursorarrow.click.2",
                    nilPropertyLabel: "per attività",
                    allCases: imputationAccountAvaible)
                .csWarningModifier(
                    warningColor: Color.hoWarning,
                    overlayAlign: .trailing,
                    padding: (.trailing,15),
                    offset: (0,0),
                    isPresented: self.generalErrorCheck,
                    localErrorCondition: {
                    self.builderVM.imputationAccountAssociated == nil
                })
        
                
            }
            
           /* let imputDescribe = self.describeImputation()
            
            Text(imputDescribe)
                .italic()
                .font(.caption)
                .foregroundStyle(Color.malibu_p53)*/
            
            
        } // chiusa vstack
        .onAppear{ builderVM.initTimeImputation() }

    } // chousa body
    
    
    @ViewBuilder private func vbPickPeriods() -> some View {
        
        let value = Binding {
            self.builderVM.sharedTimeImputation?.monthImputation?.period ?? .mensile
        } set: { newValue in
            
            self.builderVM.sharedTimeImputation?.monthImputation?.period = newValue
        }
        
        if let periodsAssociated = builderVM.periodsAssociated {
            
            if periodsAssociated.count > 1 {
                
                Picker(selection: value) {
                    
                    ForEach(periodsAssociated,id:\.self) { monthImput in
                        
                        Text(monthImput.getRawValue())
                            .tag(monthImput as HOMonthImputation.HOMIPeriod?)
                        
                    }
                    
                } label: {
                    //
                }
                .menuIndicator(.hidden)
                
            } else {
                
                Text(periodsAssociated.first?.getRawValue() ?? "error")
                    .italic()
                    .fontWeight(.semibold)
                    .fontDesign(.monospaced)
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                
            }

        } else {
            
            Text("non imputabile")
                .italic()
                .fontWeight(.semibold)
                .fontDesign(.monospaced)
                .font(.caption)
                .foregroundStyle(Color.gray)
            
        }
        
        

    }
    
   /* private func describeImputation() -> String {
        
        guard let sharedTimeImputation = builderVM.sharedTimeImputation else {
    
            return "questo tipo di operazione non viene imputata"}

        let importo = self.builderVM.sharedAmount?.imponibile
        
        let importoString = self.builderVM.sharedAmount?.imponibileStringValue

        let main = sharedTimeImputation.getImputationDescription(importo,asString: importoString)
        
        var additional:String?
        
        if let imputationAccount = self.builderVM.imputationAccount {

                additional = ", per conto \(imputationAccount.rawValue)."

        }
        
        return main + (additional ?? ".")
        
    }*/
    
}
