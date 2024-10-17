//
//  HOTimeImputation.swift
//  hoster
//
//  Created by Calogero Friscia on 17/05/24.
//

import Foundation

struct HOMonthImputation:Equatable,Hashable {
    
    var mmStart:Int?
    /// include il mese di partenza e da il n di frazionamenti
    var mmAdvancing:Int?
    
    init(startMM: Int? = nil, advancingMM: Int? = nil) {
    
        guard let advancingMM else {
            
            self.mmStart = 1
            self.mmAdvancing = 12
            return
        }
        
        self.mmStart = startMM
        self.mmAdvancing = advancingMM
    }
    
}
 
extension HOMonthImputation {
    
    var period:HOMIPeriod? {
        
        get { self.getPeriod() }
        
        set { self.setPeriod(to: newValue) }
    }
    
    func lockEditStartMM() -> Bool {
        
        guard let period else { return false }
        
        switch period {
    
        case .intero: return true
        default: return false
        
        }

    }
    
    func getNAnniImputazione() -> Int? {
        
        guard let mmStart,
              let mmAdvancing else { return nil }
        
        let advMM = Double(mmAdvancing - 1)
        let startDouble = Double(mmStart)
        
        let yyCount:Double = (advMM + startDouble) / 12
        let yyRounded:Double = yyCount.rounded(.up)
        let yyNormalize = Int(yyRounded)
        
        return yyNormalize
        
    }
    
    func getYYImputation(startYY:Int?) -> [Int]? {
        
        guard let startYY,
            let yyNormalize = self.getNAnniImputazione() else { return nil }
        
        var yyOfImputation = [startYY]
        
        while yyOfImputation.count < yyNormalize {
            
            let value = yyOfImputation.last! + 1
            yyOfImputation.append(value)
        }
        
        return yyOfImputation
    }
    
    func getMMToYY(startYY:Int) -> [Int:[Int]]? {
        
        guard let mmStart,
              let mmAdvancing else { return nil }
        
        guard let yyOfImputation = self.getYYImputation(startYY: startYY) else { return nil }
        
        var mmToYY:[Int:[Int]] = [:]
        
        var mmControlValue:Int = mmStart
        var mmControlAdvancing:Int = (mmAdvancing - 1)
            
            for eachYY in yyOfImputation {
                
                var mmIn:[Int] = [mmControlValue]
                
                while mmIn.last! < 12,
                mmControlAdvancing > 0 {
                    let new = mmIn.last! + 1
                    mmIn.append(new)
                    mmControlAdvancing -= 1
                  //  print(mmIn.last!.description)
                }
                
                mmToYY.updateValue(mmIn, forKey: eachYY)
                mmControlValue = 1
                mmControlAdvancing -= 1
            }

        return mmToYY
    }
    
    private func getPeriod() -> HOMIPeriod? {
        
        guard let mmAdvancing,
        let mmStart else { return nil }
        
        switch mmAdvancing {
            
        case 1: return .mensile
        case 2: return .bimestre
        case 3: return .trimestre
        case 4: return .quadrimestre
        case 6: return .semestre
        case 12: 
            
            switch mmStart {
                
            case 1: return .intero
            default: return .annuale
            }
            
        case 0,5,7,8,9,10,11: return nil
        
        default: return .pluriennale

        }
    }
    
    private mutating func setPeriod(to value:HOMIPeriod?) {
         
        guard let value else { return }
        guard value != period else { return }
        
        switch value {
        case .mensile,.bimestre,.trimestre,.quadrimestre,.semestre:
            self.mmAdvancing = value.getAssociatedAdvancing()
        case .annuale:
            if let mmStart,
               mmStart == 1 {
                self.mmStart = 2 // lo spostiamo a febbraio altrimenti è un intero anno
            }
            self.mmAdvancing = 12
        case .intero:
            self.mmStart = 1 // parte da gennaio per imputare l'intero anno
            self.mmAdvancing = 12
        case .pluriennale:
            return // il pluriennale non può essere settato dal periodo ma deve essere settato tramite advancing per poter caricare i mesi (anni) di ammortamento
        }
     }
    
    enum HOMIPeriod:CaseIterable {
        
        case mensile
        case bimestre
        case trimestre
        case quadrimestre
        case semestre
        case annuale
        
        case intero
        case pluriennale
        
        func getDescriptionValue() -> String {
            
            switch self {
            case .mensile:
                return "nel mese"
            case .bimestre,.trimestre:
                return "nel \(self.getRawValue())"
            case .quadrimestre:
                return "nel quadrimestre"
            case .semestre:
                return "nel semestre"
            case .annuale:
                return "nell'anno"
            case .intero:
                return "nell'anno solare"
            case .pluriennale:
                return "pluriennale"
            }
            
        }
        
        func getRawValue() -> String {
            
            switch self {
            case .mensile:
                return "mensile"
            case .bimestre:
                return "bimestre"
            case .trimestre:
                return "trimestre"
            case .quadrimestre:
                return "quadri"
            case .semestre:
                return "semestre"
            case .annuale:
                return "annuale"
            case .intero:
                return "intero anno"
            case .pluriennale:
                return "pl.ennale"
            }
            
        }
        
        func getAssociatedAdvancing() -> Int? {
        
            switch self {
            case .mensile:
                return 1
            case .bimestre:
                return 2
            case .trimestre:
                return 3
            case .quadrimestre:
                return 4
            case .semestre:
                return 6
            case .annuale,.intero:
                return 12
            case .pluriennale:
                return nil //il pluriennale è un caso specifico per gli ammortamenti e non potrà essere selezionato. Arriverà di default portando un advancing. Questo nil qui potrebbe creare problemi nel momento in cui dovessimo erroneamente permettere la selezione del pluriennale da altri periods
            }

        }

    }
    
}

extension HOMonthImputation:Codable { }

/// Contiene il mese e l'anno di imputazione a cui imputare effettivamente l'operazione. Può ovviamente differire dalla data di regolamento.
struct HOTimeImputation:Equatable,Hashable {
    
  //  var anno:[Int]?// ci serve esplicita per il fetch dei dati dal firebase ma per gli ammortamenti è fuorviante
    
    var startYY:Int? // serve per il get del yyImputation e il decoding di yyImputation. Non viene salvato su firebase
   
    var monthImputation:HOMonthImputation?
    
    var monthToYearImputation:[Int:[Int]]? { self.getMonthToYearImputation() }
    
    var yyImputation:[Int]? { self.getYYOfImputation() } // viene salvato su firebase e ci serve salvare questo per poter fetchare le operazioni in base all'anno di imputazione
}

extension HOTimeImputation {
    
    private func getYYOfImputation() -> [Int]? {
        
        guard let startYY,
              let monthImputation else { return nil }
        
        let yy = monthImputation.getYYImputation(startYY: startYY)
        return yy
        
    }
}

/// ammortamento logic
extension HOTimeImputation {
    
    var anniAmmortamento:Int? { self.getAnniAmmortamento() }
    /// equivale a 1 diviso gli anni di ammortamento
    var coefficienteAmmortamento:Double? { self.getCoefficenteAmmortamento() }
    
    var cfcAmmortamentoString:String? {
        
        guard let coefficienteAmmortamento else { return nil }
        
        let value = coefficienteAmmortamento.formatted(.percent)
        
        return "Coefficiente Ammortamento: \(value)"
        
        
    }
    
    private func getMonthToYearImputation() -> [Int:[Int]]? {
        
        guard let startYY,//let anno,
        //let firstYY = anno.first,
        let monthImputation = monthImputation else { return nil }
        
        let value = monthImputation.getMMToYY(startYY: startYY)
        
        return value
    }
    
    
    private func getAnniAmmortamento() -> Int? {
        
        guard let monthImputation,
              let advancingMM = monthImputation.mmAdvancing,
              let period = monthImputation.period,
              period == .pluriennale else { return nil }
        
        let value = advancingMM / 12
    
        guard value > 1 else {
            // vi è un errore
            return nil }
        
        return value
        
    }
    
    private func getCoefficenteAmmortamento() -> Double? {
        
        guard let anniAmmortamento else { return nil }
        
        let value = 1/Double(anniAmmortamento)
        return value
       /* guard let anno else { return nil }
        
        let ammortamento = anno.count
        
        let step_0:Double = 1/Double(ammortamento)
        return step_0*/
    }

}

/// string property formatted
extension HOTimeImputation {

    func getMonthValue() -> (first:String?,last:String?) {
        
        guard let monthImputation,
        let startMM = monthImputation.mmStart,
        let advancingMM = monthImputation.mmAdvancing else { return (nil,nil)}
        
        let firstMM = csMonthString(from: startMM)
        let normalizeAdvance = advancingMM - 1
        
        let lastMM:String?
        
        if normalizeAdvance > 0 {
            
            lastMM = csLastMonthString(from: monthImputation.mmStart, advancedBy: normalizeAdvance)
        } else {
            lastMM = nil
        }
    
        return (firstMM,lastMM)
        
    }
    
}

extension HOTimeImputation {
    
    func getQuotaMensile(from imponibile:Double?) -> String {
        
        guard let imponibile,
        let monthImputation,
        let advancingMM = monthImputation.mmAdvancing else { return "0.0"}
        
        let quota_0 = imponibile / Double(advancingMM)
        
        let quota = quota_0.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
        return quota
        
    }
    
    func getQuotaAmmortamento(from importo:Double?) -> String {
        
        guard let importo,
        let coefficienteAmmortamento else { return "0.0"}
        
        let quota_0 = importo * coefficienteAmmortamento
        
        let quota = quota_0.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
        return quota
    }
    
    func getImputationDescription(_ importo:Double?,asString:String?) -> String {
     
        guard //let anno,
              let yyImputation,
              let monthImputation,
              let period = monthImputation.period,
              let advancingMM = monthImputation.mmAdvancing,
              let importo,
              let asString else { return "error_invalid value" }
        
        let monthValue = self.getMonthValue()
    
        guard let firstMM = monthValue.first,
              let startYY else {
            return "invalid description"
        }
        
        let quotaMensile = self.getQuotaMensile(from: importo)
        
        let lastYY = yyImputation.last! // al massimo coincide con il first che è già stato swrappato
        let periodRaw = period.getDescriptionValue()
        
        let finalString:String = {
            
            if let lastMM = monthValue.last {
                
                if lastYY == startYY {
                    
                    return "\(firstMM) - \(lastMM) del \(startYY)"
                    
                } else {
                    
                    return "dal \(firstMM) del \(startYY) al \(lastMM) del \(lastYY)"
                    
                }
 
            } else {
                
                return "\(firstMM) del \(startYY)"
            }
            
        }()
        
        switch period {
        case .mensile:
            return "L'importo di \(asString) è imputato per intero al solo mese di \(finalString)"
        case .bimestre,.trimestre,.quadrimestre,.semestre,.annuale,.intero:

            return "L'importo di \(asString) è spalmato in \(advancingMM) mensilità da \(quotaMensile), \(periodRaw) \(finalString)"
   
        
        case .pluriennale:
            
            let ammortamento = self.getAnniAmmortamento() ?? 0

            return "L'importo di \(asString) è ammortizzato in \(advancingMM) quote mensili [\(ammortamento) annualità] da \(quotaMensile), \(finalString)"
            
            
            
        }

    }
    
    
   /* func getImputationDescription(_ importo:Double?,stringValue:String?) -> String {
        // l'anno deve esserci sempre
        guard let anno,
        let importo,
        let stringValue else { return "error_invalid value" }
        
        // imputazione pluriennale
        let ammortamento = anno.count
        
        if let firstYY = anno.first,
           let lastYY = anno.last,
           firstYY != lastYY,
           let monthString,
           let firstMM = monthString.first,
           let lastMM = monthString.last {
            
           // let years = self.getYearsAmmortamento()
            let quota = self.getQuotaAmmortamento(from: importo)
            
            return "L'importo di \(stringValue) è ammortizzato in \(ammortamento) annualità \(anno.description) da \(quota). Dal \(firstMM) del \(firstYY - 1) al \(lastMM) del \(lastYY)"
        
        }
        // ammortamento nil
        // imputazione nel mese per l'anno
        else if let monthString {
            
            return "L'importo di \(stringValue) è imputato al solo mese di \(monthString) del \(anno)"
            
        }
        // mese e ammortamento nil
        // imputazione per l'anno
        else {
            
            return "L'importo di \(stringValue) è imputato in parti uguali a ciascun mese dell'anno \(anno)"
        }

    }*/
    
    
}

extension HOTimeImputation: Decodable {
    
    enum CodingKeys:String,CodingKey {
        
        case monthImputation
        case yyImputation
        
    }
    
    init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.monthImputation = try container.decodeIfPresent(HOMonthImputation.self, forKey: .monthImputation)
        let years = try container.decodeIfPresent([Int].self, forKey: .yyImputation)
        self.startYY = years?.first
        
    }
    
}

extension HOTimeImputation:Encodable {
    
    func encode(to encoder: any Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.monthImputation, forKey: .monthImputation)
        try container.encodeIfPresent(self.yyImputation, forKey: .yyImputation)
        
    }
    
}


// NUOVA VERSIONE

struct HOImputationPeriod:Equatable {
    
    var start:Date?
    var end:Date?
    /// da la distanza fra lo start e l'end in giorni
    var ddDistance:Int? {
        
        get { self.getDistance() }
        set { self.setDistance(newValue: newValue) }
    }
    
    var calendar:Calendar { Locale.current.calendar }
}

extension HOImputationPeriod {
    
    func getIntersectionWith(year:Int,mm:Int?) -> DateInterval? {
        
        guard let dateInterval else { return nil }
        
        let specularDate = DateComponents(calendar:calendar,year: year,month: mm).date
        
        guard let specularDate else { return nil }
        
        var specularInterval:DateInterval?
        
        if let _ = mm {
            
            specularInterval = calendar.dateInterval(of: .month, for: specularDate)
            
        } else {
            
            specularInterval = calendar.dateInterval(of: .year, for: specularDate)
            
        }
        
        guard let specularInterval else { return nil }
        
        let result = dateInterval.intersection(with: specularInterval)
        return result
        
    }
    
}

extension HOImputationPeriod {
    
    var dateInterval:DateInterval? { self.getDateInterval() }
    
    private func getDateInterval() -> DateInterval? {
        
        guard let start,
              let end else { return nil }
        
        let interval = DateInterval(start: start, end: end)
        return interval
    }
    
   /* func updateSelf() -> HOImputationPeriod? {
        
        guard let start,
              let end else { return nil }
        
        let start_compo = calendar.dateComponents([.month,.year,.day], from: start)
        
        let end_compo = calendar.dateComponents([.month,.year,.day], from: end)
        
    
        let newStart = DateComponents(calendar:calendar,year: start_compo.year,month: start_compo.month,day: start_compo.day).date
        
        let newEnd = DateComponents(calendar:calendar,year: end_compo.year,month: end_compo.month,day: end_compo.day).date
        
        return HOImputationPeriod(start: newStart, end: newEnd)
        
    }*/ // temporanea
    
}

extension HOImputationPeriod:Decodable {
    
    enum CodingKeys: String, CodingKey {
        case start
        case end
    }
    
    init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let savedStart = try container.decodeIfPresent(Date.self, forKey: .start)
        let savedEnd = try container.decodeIfPresent(Date.self, forKey: .end)
        
        self.start = updateDecodedDate(from:savedStart)
        self.end = updateDecodedDate(from:savedEnd)
        
    }
    /// Usiamo un update per conformare tutte le date salvate ad un orario standard che sarà nil aka 24:00 or 12:00 AM. La conformità è basilare per le operazioni sulle date per ottenere intervalli di giorni in modo corretto
    private func updateDecodedDate(from savedDate:Date?) -> Date? {
        
        guard let savedDate else { return nil }
        
        let compo = calendar.dateComponents([.month,.year,.day], from: savedDate)
        
        let newDate = DateComponents(calendar:calendar,year: compo.year,month: compo.month,day: compo.day).date
        
        return newDate
    }
}

extension HOImputationPeriod:Encodable {
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.start, forKey: .start)
        try container.encodeIfPresent(self.end, forKey: .end)
    }
}

extension HOImputationPeriod {
    
    private func getDistance() -> Int? {
        
        guard let start,
              let end else { return nil }
        
        let days = self.calendar.dateComponents([.day], from: start, to: end)
        return days.day
    }
    
    mutating func setDistance(newValue:Int?) {
        
        guard let newValue,
              let start else { return }
        
        let out = self.calendar.date(byAdding: .day, value: newValue, to: start)
        self.end = out
        
    }
    
}
 

