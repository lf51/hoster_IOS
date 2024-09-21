//
//  HOOperationRowView.swift
//  hoster
//
//  Created by Calogero Friscia on 03/09/24.
//

import SwiftUI
import MyPackView

struct HOOperationRowView: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    let operation:HOOperationUnit
    @State private var openOperationDetail:Bool = false
    
    var body: some View {
        
        VStack(spacing:2) {
            
            CSZStackVB_Framed() {
                
              //  VStack(alignment:.leading,spacing: 10) {
                    
                  //  vbFirstLine()
                   
                    VStack(alignment:.leading,spacing:5) {
                        
                        vbSecondLine()
                        vbAmountLine()
                    }
                    
              //  }
                .padding(.horizontal,10)
                .padding(.vertical,5)
                
            } // chiusa framedr
            
            if openOperationDetail {
                
                vbOperationDetail()
                    .onTapGesture {
                        withAnimation {
                            self.openOperationDetail = false
                        }
                    }
            }
        }
        
    } // chiusa body
    
    @ViewBuilder private func vbOperationDetail() -> some View {
        
        CSZStackVB_Framed(backgroundOpacity:0.15) {
            
            LazyVStack(alignment:.leading) {
                
                vbFirstLine()
                
            }
            .padding(.horizontal,10)
            .padding(.vertical,5)
        }
    }
    
    @ViewBuilder private func vbSecondLine() -> some View {
        
        let description = self.operation.writing?.oggetto?.getDescription(campi: \.category,\.subCategory) ?? "no value"
        let specific = self.operation.writing?.oggetto?.getDescription(campi: \.specification) ?? "no value"
        let specificNormalize = csCutString(value: specific, character: "#")
       
        
        VStack(alignment:.leading,spacing:0) {
            
            Text(specificNormalize)
                .italic()
                .fontWeight(.semibold)
                .font(.title3)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
            
            Text("[\(description)]")
                .fontWeight(.semibold)
                .font(.subheadline)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
        }
        .foregroundStyle(Color.black)
        
    }
    
    @ViewBuilder private func vbFirstLine() -> some View {
        
        let label = self.operation.writingLabel.csCapitalizeFirst()
        let imputation = self.operation.writing?.imputationStringValue ?? "no value"
        
        let contabileData = csTimeFormatter(style:.medium).data.string(from: self.operation.regolamento)
        
        let currentYY:Int = self.viewModel.yyFetchData
        let months = self.operation.getMonthsImputationString(for: currentYY) ?? ["no value"]
        let mmIncipit = csSwitchSingolarePlurale(checkNumber: months.count, wordSingolare: "nel mese", wordPlurale: "nei mesi")
        
        VStack(alignment:.leading,spacing: 5) {
            
            VStack(alignment:.leading,spacing:0) {
                
                Text("Operazione di \(label)")
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    
                Text("regolata il \(contabileData)")
                    .opacity(0.8)
                
            }
            .font(.subheadline)
            .fontDesign(.monospaced)
            .foregroundStyle(Color.black)
  
            VStack(alignment:.leading,spacing:0) {
                
                Text("Imputazione \(imputation)")
                    .fontWeight(.semibold)
                    
                Text("per l'anno \(currentYY.description)")
                
                Text("\(mmIncipit) di: \(months,format: .list(type: .and))")
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                
            }
            .font(.subheadline)
            .fontDesign(.monospaced)
            .foregroundStyle(Color.black)
            
        }

    }
    
    @ViewBuilder private func vbAmountLine() -> some View {
        
        let total = self.operation.amount?.imponibileStringValue ?? "no value"
        
        let misureUnit = self.operation.quantityAmountMisureUnit
        let q = self.operation.amount?.getQuantityStringValue(coerent: misureUnit) ?? "no value"
        
        let signColor = self.operation.writing?.type?.getColorAssociated() ?? Color.gray
        
        let buttonImage:String = {
            
            if self.openOperationDetail {
                return "chevron.compact.up"
            } else {
                return "chevron.compact.down"
            }
        }()
        
        HStack() {
         
            Text("\(q) \(misureUnit.rawValue)")
                  .font(.headline)
                 // .fontDesign(.monospaced)
                  .foregroundStyle(Color.black)
                 // .kerning(1)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    self.openOperationDetail.toggle()
                }
                
            }, label: {
                Image(systemName: buttonImage)
                    .bold()
                    .imageScale(.large)
                    .foregroundStyle(Color.hoAccent)
                    .offset(x:0,y:10)
            })
            
            Spacer()
            
            Text(total)
                .font(.title2)
                .bold()
                .foregroundStyle(signColor)
            
        }
        
    }


}

#Preview {
    HOOperationRowView(operation: HOOperationUnit())
}
