//
//  Untitled 3.swift
//  hoster
//
//  Created by Calogero Friscia on 19/10/24.
//
import SwiftUI

struct HOReportGridRow:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    let mainValue:Double
    let inquiryPath:HOInquiryPath
    
    let position:Int
    let label:String
    
    let mmOrdinal:Int?
    let subUid:String?
    
    var body: some View {
        
        GridRow {
            
            let value = self.getRelatedValue(in:mmOrdinal,for: subUid)
            
            Text("\(position)")
                .frame(width: 25, height: 17)
                //.font(.subheadline)
                .fontDesign(.monospaced)
                .foregroundStyle(Color.cinderella_p47)
                .background(Color.hoBackGround)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            Text(label)
                .fontWeight(.semibold)
               // .font(.subheadline)
                .fontDesign(.monospaced)
                .foregroundStyle(Color.cinderella_p47)
                .fixedSize()
                
           RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color.gray)
                .opacity(0.2)
                .frame(width:100,height: 5)
                .overlay(alignment:.leading) {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(value.barraColor.gradient)
                        .frame(width:value.barra,height: 5)
                }
            
            Text("\(value.incidenza,format: .percent)")
                .font(.caption2)
                .foregroundStyle(Color.gray)
            
            Spacer()

            Text("\(value.local,format:inquiryPath.getUnitMisureAssociated())")
                .fontWeight(.bold)
                .foregroundStyle(Color.scooter_p53)
                .gridColumnAlignment(.trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

              
        }
        
    } // chiusa body
    
    private func getRelatedValue(in monthOrdinal:Int?,for subUid:String?) -> (local:Double,incidenza:Double,barra:CGFloat,barraColor:Color) {

        let value = self.inquiryPath.getInquiryValue(for: monthOrdinal,subUid: subUid, viewModel: self.viewModel)
        
        let incidenza:Double = {
            
            let start = value / mainValue
            let step_2 =  String(format: "%.3f", start)
            return Double(step_2) ?? 0
        }()
        
        let barra:Double = {
            
            let start = 100 * incidenza
            
            if start > 100 { return 100 }
            else if start < 0 { return 0 }
            else if start.isNaN { return 0 }
            
            return start
        }()
        
        let colorBarra:Color = {
            
            switch incidenza {
            case 0..<0.25: return Color.red
                
            case 0.25..<0.75: return Color.orange
                
            case 0.75..<1.0: return Color.yellow
                
            default: return Color.green
            }
            
            
        }()
        
        return (value,incidenza,barra,colorBarra)
    }
}
