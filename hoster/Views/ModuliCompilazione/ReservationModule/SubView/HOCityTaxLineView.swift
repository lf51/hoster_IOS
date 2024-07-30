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
    
    @ObservedObject var builderVM:HONewReservationBuilderVM
       
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

                    HStack {
                        
                        CS_ErrorMarkView(
                            warningColor: .yellow,
                            scale: .medium,
                            padding: (.trailing,0),
                            generalErrorCheck: true,
                            localErrorCondition:
                            !isTaxApplied)
                        
                        Spacer()
                        
                        HOInfoMessageView(
                            messageBody: HOSystemMessage(
                                vector: .log,
                                title: "INFO",
                                body: .custom(self.getInfo())))
                    }
                    
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
                            labelText: Color.hoAccent,
                            labelBackground: Color.hoBackGround,
                            image: nil,
                            imageColor: nil,
                            valueColor: Color.white,
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

    private func getInfo() -> String {
        
        "La Tassa di soggiorno è generalmente applicata sui pernottamenti. L'importo e le esenzioni variano da comune a comune.\nL'applicativo applica l'importo (da impostare nel setup) su tutti i pernottamenti previsti. Usare il campo esenzione per correggere sulla base della normativa locale."
        
    }
    
    
    @ViewBuilder private func vbCityTaxtBox() -> some View {
        
        let value = Double(self.builderVM.pernottamentiTassati) * self.builderVM.cityTax
        
       HStack {
            
           Image(systemName: "plus.circle")
               .imageScale(.medium)
               .foregroundColor(Color.green)
           
            Text("City Tax")
               .italic()
               // .fontDesign(.monospaced)
                .fontWeight(.regular)
                .font(.subheadline)
                .foregroundStyle(Color.hoDefaultText)
           
           Spacer()
           
           Text("\(value,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
               // .italic()
                .fontWeight(.bold)
                .font(.body)
                .foregroundStyle(Color.malibu_p53)
               // .lineLimit(1)
         //  Spacer()
        }
        .padding(.leading,2)
        .padding(.trailing,10)
        //.padding(.horizontal,10)
        .padding(.vertical,5)
        .background {
            
            RoundedRectangle(cornerRadius: 5.0)
                .foregroundStyle(Color.hoBackGround)
               // .frame(maxWidth:.infinity)
               
        }
        
    }
    
    
    
}

struct HOCommissionableLineView:View {
    
    @ObservedObject var builderVM:HONewReservationBuilderVM
    @FocusState.Binding var focusField:HOReservation.FocusField?
    let generalErrorCheck:Bool 
    
    var body: some View {
        
        let placeHolder = String(self.builderVM.commissionable ?? 0.0)
        let localError:Bool = self.builderVM.commissionable == nil
        
        let image:(name:String,color:Color) = {
            
            if generalErrorCheck,
            localError {
                
                return ("exclamationmark.triangle.fill",Color.hoWarning)
            }
            else if localError { return ("eurosign.circle.fill",Color.gray) }
            else {
                return ("eurosign.circle.fill",Color.green)
            }
            
        }()
        
            CSSyncTextField_4b(
                placeHolder: placeHolder,
                showDelete: false,
                keyboardType:.decimalPad,
                focusValue: HOReservation.FocusField.commisionabile,
                focusField: $focusField) {
                
                HStack(spacing:5) {
                    
                    Text("Entrata Lorda")
                        .foregroundStyle(.white)
                        .bold()
                        .padding(.vertical,10)
                        .padding(.horizontal,6)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green.opacity(0.5))
                        }
                    Image(systemName: image.name)
                        .imageScale(.large)
                        .bold()
                        .foregroundStyle(image.color)
                }
                
            } disableLogic: { value in
                
                let converted = csConvertToDotDouble(from: value)
                return converted == 0.0
                
            } syncroAction: { new in
            
                let converted = csConvertToDotDouble(from: new)
                self.builderVM.commissionable = converted
            }
        
    }
}

struct HOOTACommissionLineView: View {
    
    @ObservedObject var builderVM:HONewReservationBuilderVM
    @State private var quantityStepIncrement:Double = 1
    
    var body: some View {
       
                    let disableStep = self.builderVM.portale?.commissionValue == nil
                    
                    HStack {
                        
                        CSSinkStepper_decimal(
                            initialValue: self.builderVM.portale?.commissionValue,
                            range: 0...100,
                            step: quantityStepIncrement,
                            label: "Commissione",
                            labelText: Color.hoAccent,
                            labelBackground: Color.hoBackGround,
                            image: "percent",
                            imageColor: nil,
                            valueColor: Color.white,
                            numberWidth: 50) { _, newValue in
                                self.builderVM.portale?.commissionValue = newValue
                            }
                            .fixedSize()

                        Button {
                            
                            self.setIncrement()
                            
                        } label: {
                            
                            Text("+ \(self.quantityStepIncrement,format: .number)")
                                .bold()
                                .font(.callout)
                                .foregroundStyle(Color.hoAccent)
                        }.buttonBorderShape(.roundedRectangle)
                        
                    }
                    .opacity(disableStep ? 0.6 : 1.0)
                    .disabled(disableStep)

        
    } // chiusa body
    
    private func setIncrement() {
        
        let current = self.quantityStepIncrement
        
        if current == 1 { self.quantityStepIncrement = 0.1 }
        else { self.quantityStepIncrement = 1 }
        
    }
}

struct HOCostiTransazioneLineView: View {

    @ObservedObject var builderVM:HONewReservationBuilderVM
    @State private var quantityStepIncrement:Double = 1
    
    var body: some View {
 
        let disableStep = self.builderVM.portale == nil
                    
                    HStack {
                        
                        CSSinkStepper_decimal(
                            initialValue: self.builderVM.transazioneValue,
                            range: 0...100,
                            step: quantityStepIncrement,
                            label: "Transazione",
                            labelText: Color.hoAccent,
                            labelBackground: Color.hoBackGround,
                            image: "percent",
                            imageColor: nil,
                            valueColor: Color.white,
                            numberWidth: 50) { _, newValue in
                                self.builderVM.transazioneValue = newValue
                            }
                            .fixedSize()
                           
                     
                        Button {
                            
                            self.setIncrement()
                            
                        } label: {
                            
                            Text("+ \(self.quantityStepIncrement,format: .number)")
                                .bold()
                                .font(.callout)
                                .foregroundStyle(Color.hoAccent)
                        }.buttonBorderShape(.roundedRectangle)
                        
                    }
                    .opacity(disableStep ? 0.6 : 1.0)
                    .disabled(disableStep)
                   
        
    } // chiusa body
    
    private func setIncrement() {
        
        let current = self.quantityStepIncrement
        
        if current == 1 { self.quantityStepIncrement = 0.1 }
        else { self.quantityStepIncrement = 1 }
        
    }
    
}

struct HOCostoIvaLineView: View {
    
    @ObservedObject var builderVM:HONewReservationBuilderVM
    @State private var quantityStepIncrement:Double = 1
    
    var body: some View {
       
        let disableStep:Bool = {
            
            let conditionOne = self.builderVM.portale == nil
            let conditionTwo = (self.builderVM.costoCommissione + self.builderVM.costoTransazione) == 0
            
            return conditionOne || conditionTwo
        }()
                    
                    HStack {
                        
                        CSSinkStepper_decimal(
                            initialValue: self.builderVM.ivaValue,
                            range: 0...100,
                            step: quantityStepIncrement,
                            label: "Iva sui Costi",
                            labelText: Color.hoAccent,
                            labelBackground: Color.hoBackGround,
                            image: "percent",
                            imageColor: nil,
                            valueColor: Color.white,
                            numberWidth: 50) { _, newValue in
                                self.builderVM.ivaValue = newValue
                            }
                            .fixedSize()
                           
                     
                        Button {
                            
                            self.setIncrement()
                            
                        } label: {
                            
                            Text("+ \(self.quantityStepIncrement,format: .number)")
                                .bold()
                                .font(.callout)
                                .foregroundStyle(Color.hoAccent)
                        }.buttonBorderShape(.roundedRectangle)
                        
                    }
                    .opacity(disableStep ? 0.6 : 1.0)
                    .disabled(disableStep)

    } // chiusa body
    
    private func setIncrement() {
        
        let current = self.quantityStepIncrement
        
        if current == 1 { self.quantityStepIncrement = 0.1 }
        else { self.quantityStepIncrement = 1 }
        
    }

}

struct HOAmountResumeLineView:View {
    
    @ObservedObject var builderVM:HONewReservationBuilderVM
    
    var body: some View {
        
        VStack(alignment: .leading,spacing: 5) {
            
            vbCommissionBox()
            vbTransazioneBox()
            if let _ = builderVM.ivaValue {
                
                vbIvaBox()
            }
            vbNetIncomeBox()
        }
        
    } // chiusa body
        
    @ViewBuilder private func vbNetIncomeBox() -> some View {
        
        let label:String = {
            
            guard let portale = builderVM.portale,
                  portale.label != HOOTADefaultCase.direct.rawValue else { return "Entrata Netta" }
            
            return "Netto da Portale"
            
        }()
        
       HStack {
            
           Image(systemName: "equal.circle.fill")
               .imageScale(.medium)
               .foregroundColor(Color.malibu_p53)
           
            Text(label)
               .italic()
                //.fontDesign(.monospaced)
                .fontWeight(.semibold)
               // .font(.headline)
                .foregroundStyle(Color.hoDefaultText)
                
           Spacer()
           
           Text("\(self.builderVM.netIncome,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
               // .italic()
                .fontWeight(.bold)
               // .font(.body)
                .foregroundStyle(Color.malibu_p53)
               // .lineLimit(1)
         //  Spacer()
        }
        .font(.title3)
        .padding(.leading,2)
        .padding(.trailing,10)
       // .padding(.horizontal,10)
        .padding(.vertical,5)
        .background {
            
            RoundedRectangle(cornerRadius: 5.0)
                .fill(Color.hoBackGround.gradient)
                //.foregroundStyle(Color.hoBackGround.gradient)
               // .frame(maxWidth:.infinity)
               
        }
        
    }
    @ViewBuilder private func vbIvaBox() -> some View {
        
        HStack {
            
            Image(systemName: "minus.circle")
                .imageScale(.medium)
                .foregroundColor(Color.red)
            
            Text("Iva come Costo")
                .italic()
                //.fontDesign(.monospaced)
                .fontWeight(.regular)
                .font(.subheadline)
                .foregroundStyle(Color.hoDefaultText)
            
            Spacer()
            
            Text("\(self.builderVM.ivaAsCost,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
            // .italic()
                .fontWeight(.bold)
                .font(.body)
                .foregroundStyle(Color.gray)
            // .lineLimit(1)
            //  Spacer()
        }
        // .padding(.horizontal,10)
        .padding(.leading,2)
        .padding(.trailing,10)
        .padding(.vertical,5)
        .background {
            
            RoundedRectangle(cornerRadius: 5.0)
                .foregroundStyle(Color.hoBackGround)
            // .frame(maxWidth:.infinity)
            
        }
        
    }
        
    @ViewBuilder private func vbTransazioneBox() -> some View {
        
       HStack {
            
           Image(systemName: "minus.circle")
               .imageScale(.medium)
               .foregroundColor(Color.red)
           
            Text("Costi di Transazione")
               .italic()
               // .fontDesign(.monospaced)
                .fontWeight(.regular)
                .font(.subheadline)
                .foregroundStyle(Color.hoDefaultText)
                
           Spacer()
           
           Text("\(self.builderVM.costoTransazione,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
               // .italic()
                .fontWeight(.bold)
                .font(.body)
                .foregroundStyle(Color.gray)
               // .lineLimit(1)
         //  Spacer()
        }
       
       // .padding(.horizontal,10)
        .padding(.leading,2)
        .padding(.trailing,10)
        .padding(.vertical,5)
        .background {
            
            RoundedRectangle(cornerRadius: 5.0)
                .foregroundStyle(Color.hoBackGround)
               // .frame(maxWidth:.infinity)
               
        }
        
    }
    
    @ViewBuilder private func vbCommissionBox() -> some View {
        
       HStack {
            
           Image(systemName: "minus.circle")
               .imageScale(.medium)
               .foregroundColor(Color.red)
           
            Text("Costo Commissione")
               .italic()
                //.fontDesign(.monospaced)
               .fontWeight(.regular)
                .font(.subheadline)
                .foregroundStyle(Color.hoDefaultText)
                
           Spacer()
           
           Text("\(self.builderVM.costoCommissione,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
               // .italic()
                .fontWeight(.bold)
                .font(.body)
                .foregroundStyle(Color.gray)
               // .lineLimit(1)
         //  Spacer()
        }
        .padding(.leading,2)
        .padding(.trailing,10)
       // .padding(.horizontal,10)
        .padding(.vertical,5)
        .background {
            
            RoundedRectangle(cornerRadius: 5.0)
                .foregroundStyle(Color.hoBackGround)
               // .frame(maxWidth:.infinity)
               
        }
        
    }
    }
    
