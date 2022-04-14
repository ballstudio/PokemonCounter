//
//  PMDataModel.swift
//  PokemonCounter
//
//  Created by Mictel on 2022/4/2.
//

import Foundation
import CoreData
import SwiftUI
import Combine

public class PMDataModel{
    private weak var dataContext: NSManagedObjectContext? = nil
    
    enum DefaultTemplateMode: String{
        case default7 = "组合法 7 只"
        case default8 = "组合法 8 只"
        case default9 = "组合法 9 只"
        case default10 = "组合法 10 只"
        case distance = "距离法 4 只"
        
        static let allValues = [default7, default8, default9, default10, distance]
        func count() -> Int{
            switch self {
            case .default7:
                return 7
            case .default8:
                return 8
            case .default9:
                return 9
            case .default10:
                return 10
            case .distance:
                return 4
            }
        }
    }
    
    init(dataContext: NSManagedObjectContext){
        self.dataContext = dataContext
    }
            
    func getDefaultTemplateCounters(mode: DefaultTemplateMode) -> NSOrderedSet{
        return self.getCounters(mode: mode)
    }
    
    func addCounts(counters: NSMutableOrderedSet, countersString: String, modeCount: Int){
        for counter in countersString.split(separator: ","){
            counters.add(self.makeCounter(values: String(counter), modeCount: modeCount))
        }
    }
    
    func getCounters(mode: DefaultTemplateMode) -> NSOrderedSet{
        let counters = NSMutableOrderedSet()
        
        switch mode {
        case .default7:
            self.addCounts(counters: counters,countersString: "1,112,113,114,121,131,141,2,22,23,24,3,4",modeCount: 7)
            break;
        case .default8:
            self.addCounts(counters: counters,countersString: "1,1112,1113,1114,112,113,114,121,122,123,124,131,141,2,212,213,214,221,231,241,3,321,331,341,4",modeCount: 8)
            break;
        case .default9:
            self.addCounts(counters: counters,countersString: "1,11112,11113,11114,1112,1113,1114,112,1122,1123,1124,113,114,121,1212,1213,1214,122,123,124,13,132,133,134,14,2,2112,2113,2114,212,213,214,22,222,223,224,23,24,3,312,313,314,32,33,34,4,42,43,44",modeCount: 9)
            break;
        case .default10:
            self.addCounts(counters: counters,countersString: "1,111112,111113,111114,11112,11113,11114,1112,11122,11123,11124,1113,1114,112,11212,11213,11214,1122,1123,1124,113,1132,1133,1134,114,12,12112,12113,12114,1212,1213,1214,1221,1222,1223,1224,123,124,13,1312,1313,1314,132,133,134,14,142,143,144,2,21112,21113,21114,2112,2113,2114,2121,2122,2123,2124,2131,2141,22,2212,2213,2214,222,223,224,23,232,233,234,24,3,3112,3113,3114,4121,3131,3141,32,322,323,324,33,34,4,412,413,414,42,43,44",modeCount: 10)
            break;
        case .distance:
            self.addCounts(counters: counters,countersString: "1111,112,121,13,211,22,31,4",modeCount: 4)
            break;
        }
        
        return counters
    }
    
    func makeCounter(values: String ,modeCount: Int) -> PMCounter{
        guard let dc = self.dataContext else{
            fatalError("not set data context.")
        }

        let counter = PMCounter(context: dc)
        
        var s = 0
        var v = ""
        for value in values{
            if let value = Int(String(value)){
                v += String(value)
                s += value
            }
        }
        if s < modeCount{
            for _ in s+1 ... modeCount{
                v += "1"
            }
        }
        
        counter.ruler = v
        counter.finished = false
        counter.finishTime = Date()
        counter.shiny = false
        return counter
    }
    
    func lastCounterGroup(mode: DefaultTemplateMode) -> PMCounterGroup?{
        guard let dc = self.dataContext else{
            fatalError("not set data context.")
        }
        
        let fetchRequest = NSFetchRequest<PMCounterGroup>(entityName: "PMCounterGroup")
        let predicate = NSPredicate(format: "templateName == %@", mode.rawValue)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        do{
            let fetchObjects = try dc.fetch(fetchRequest)
            if fetchObjects.count > 0{
                return fetchObjects.last
            }else{
                return nil
            }
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    func getCounterGroups(mode: DefaultTemplateMode) -> [PMCounterGroup]{
        guard let dc = self.dataContext else{
            fatalError("not set data context.")
        }
        
        let fetchRequest = NSFetchRequest<PMCounterGroup>(entityName: "PMCounterGroup")
        let predicate = NSPredicate(format: "templateName == %@", mode.rawValue)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        do{
            let fetchObjects = try dc.fetch(fetchRequest)
            
            for group in fetchObjects{
                group.shiny = self.getShinyCount(group: group) > 0
            }
            
            return fetchObjects
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    func getShinyCount(mode: DefaultTemplateMode) -> Int{
        guard let dc = self.dataContext else{
            fatalError("not set data context.")
        }
        
        let fetchRequest = NSFetchRequest<PMCounter>(entityName: "PMCounter")
        fetchRequest.resultType = .countResultType
        let predicate = NSPredicate(format: "group.templateName == %@ AND shiny == %@", mode.rawValue, NSNumber (value: true))
        fetchRequest.predicate = predicate
        do{
            let count = try dc.count(for: fetchRequest)
            print(count)
        }catch{
            fatalError(error.localizedDescription)
        }

        return 0
    }
    
    func getShinyCounts(mode: DefaultTemplateMode, currentGroup:PMCounterGroup? = nil) -> [Any]{
        guard let dc = self.dataContext else{
            fatalError("not set data context.")
        }
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "PMCounter")
        var predicate = NSPredicate(format: "group.templateName == %@ AND shiny == %@", mode.rawValue, NSNumber (value: true))
        
        if currentGroup != nil{
            predicate = NSPredicate(format: "group != %@ AND group.templateName == %@ AND shiny == %@", currentGroup!, mode.rawValue, NSNumber (value: true))
        }
        
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .dictionaryResultType
        
        let sumExpression = NSExpression(format: "count:(shiny)")
        let sumED = NSExpressionDescription()
        sumED.expression = sumExpression
        sumED.name = "shinyCount"
        sumED.expressionResultType = .integer32AttributeType
        
        fetchRequest.propertiesToFetch = ["ruler", sumED]
        fetchRequest.propertiesToGroupBy = ["ruler"]

        
        do{
            let fetchRequests = try dc.fetch(fetchRequest)
            return fetchRequests
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    func getShinyCount(group: PMCounterGroup) -> Int{
        guard let dc = self.dataContext else{
            fatalError("not set data context.")
        }
        
        let fetchRequest = NSFetchRequest<PMCounter>(entityName: "PMCounter")
        fetchRequest.resultType = .countResultType
        let predicate = NSPredicate(format: "group == %@ AND shiny == %@", group, NSNumber (value: true))
        fetchRequest.predicate = predicate
        do{
            return try dc.count(for: fetchRequest)
        }catch{
            fatalError(error.localizedDescription)
        }
    }
}

public class PMCounterGroupController: ObservableObject{
    @Published var counters = PMCounterCollectionController(collection: [])
    
    @Published var filterCounters = PMCounterCollectionController(collection: [])
    @Published var finishedCounters = PMCounterCollectionController(collection: [])
    @Published var unFinishedCounters = PMCounterCollectionController(collection: [])
    
    @Published var currentCounter = PMCounterController()
    
    private var cs: Set<AnyCancellable> = []
    
    weak var dataContext: NSManagedObjectContext? = nil
    var counterGroup: PMCounterGroup? = nil
    
    @Published var memo:String = ""
    @Published var timestamp:Date = Date()

    init(){
        $counters
            .receive(on: RunLoop.main)
            .map{ rulers in
                let collection = rulers.collection.filter({ ruler in
                    return ruler.finished == false
                })
                return PMCounterCollectionController(collection: collection)
            }
            .assign(to: \.unFinishedCounters, on: self)
            .store(in: &cs)
        
        $counters
            .receive(on: RunLoop.main)
            .map{ rulers in
                let collection = rulers.collection.filter({ ruler in
                    return ruler.finished == true
                }).sorted { lh, rh in
                    return lh.finishTime > rh.finishTime
                }
                return PMCounterCollectionController(collection: collection)
            }
            .assign(to: \.finishedCounters, on: self)
            .store(in: &cs)
        
        Publishers.CombineLatest($counters, $currentCounter)
            .receive(on: RunLoop.main)
            .map{(rulers, currentRuler) in
                let collection = rulers.collection.filter({ ruler in
                    if currentRuler.description == ""{
                        return false
                    }
                    return ruler.description.hasPrefix(currentRuler.description) && !ruler.finished
                })
                return PMCounterCollectionController(collection: collection)
            }
            .assign(to: \.filterCounters, on: self)
            .store(in: &cs)
    }
    
    func load(counterGroup: PMCounterGroup, dataContext: NSManagedObjectContext, showShinyCount: Bool){
        self.dataContext = dataContext
        self.counterGroup = counterGroup
        
        self.memo = counterGroup.memo ?? ""
        self.timestamp = counterGroup.timestamp!

        self.counters.collection.removeAll()
        if let templateName = counterGroup.templateName, let mode = PMDataModel.DefaultTemplateMode(rawValue: templateName){
            let shinyCounts = PMDataModel(dataContext: dataContext).getShinyCounts(mode: mode, currentGroup: counterGroup)

            for counter in counterGroup.counters!.array{
                let counterController = self.addCounter(counter: counter as! PMCounter, modeCount: mode.count())
                
                if showShinyCount{
                    for shinyCount in shinyCounts{
                        if let bc = shinyCount as? Dictionary<String, Any>{
                            if bc["ruler"] as! String == counterController.counter!.ruler!{
                                counterController.shinyCount = bc["shinyCount"]! as! Int
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addCounter(counter: PMCounter, modeCount: Int) -> PMCounterController{
        let counter = PMCounterController(counter: counter, modeCount: modeCount)
        counter.counterGroup = self
        self.counters.collection.append(counter)
        return counter
    }
    
    func save(){
        guard let dataContext = dataContext else{
            fatalError("not set data context.")
        }
        
        do{
            try dataContext.save()
        }catch{
            fatalError(error.localizedDescription)
        }
    }
}

public class PMCounterCollectionController: ObservableObject{
    @Published var collection = [PMCounterController]()
    
    init(collection: [PMCounterController]){
        self.collection = collection
    }
}

public class PMCounterController: CustomStringConvertible, ObservableObject, Identifiable{
    @Published var ruler = [Int]()
    @Published var finished = false
    @Published var finishTime = Date()
    @Published var shiny = false
    @Published var shinyCount = 0
    
    weak var counterGroup: PMCounterGroupController? = nil

    weak var counter: PMCounter? = nil

    init(){
        
    }
    
    init(counter: PMCounter, modeCount: Int){
        self.counter = counter
        self.load(string: counter.ruler!, modeCount: modeCount, finished: counter.finished, finishTime: counter.finishTime ?? Date(), shiny: counter.shiny)
    }
        
    func load(string: String, modeCount: Int, finished: Bool = false, finishTime: Date = Date(), shiny: Bool = false){
        var cs = [Int]()
        var sum = 0
        for c in string{
            if let ci = Int(String(c)){
                cs.append(ci)
                sum += ci
            }
        }
        
        if sum < modeCount{
            for _ in sum + 1...modeCount{
                cs.append(1)
            }
        }
        
        self.ruler = cs
        self.finished = finished
        self.finishTime = finishTime
        self.shiny = shiny
    }
    
    public var description: String{
        get{
            var value = ""
            for ruler in self.ruler {
                value += "\(ruler)"
            }
            return value
        }
    }
    
    func body(hideCount:Int = 0) -> some View {
        HStack(spacing:0){
            ForEach(self.ruler.indices, id:\.self){ inx in
                Text("\(self.ruler[inx])")
                    .frame(width: 22, height: 30, alignment: .center)
                    .opacity(inx < hideCount ? 0.5 : 1.0)
                    .font(Font.system(size: 16, weight: Font.Weight.bold, design: Font.Design.rounded))
            }
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        .background(
            self.counterGroup == nil ? LinearGradient(gradient: Gradient(colors: [Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0).opacity(0.8), Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0)]), startPoint: .bottom, endPoint: .top) : ( !self.finished ? LinearGradient(gradient: Gradient(colors: [redColor.opacity(0.6), redColor.opacity(0.8)]), startPoint: .top, endPoint: .bottom) : LinearGradient(gradient: Gradient(colors: [greenColor.opacity(0.6), greenColor.opacity(0.8)]), startPoint: .top, endPoint: .bottom)))
        .cornerRadius(15)
        .foregroundColor(self.counterGroup != nil ? .white : barColor2)
        .font(.system(size: 15))
    }
}
