//
//  HistoryView.swift
//  PokemonCounter (iOS)
//
//  Created by Mictel on 2022/4/3.
//

import SwiftUI
import CoreData

let rulersRowHeight:CGFloat = 55.0

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var mode: PMDataModel.DefaultTemplateMode = .default7
    var currentGroup :PMCounterGroup? = nil
    
    @State var groups = [PMCounterGroup]()
    
    init(mode: PMDataModel.DefaultTemplateMode, currentGroup: PMCounterGroup?){
        self.mode = mode
        self.currentGroup = currentGroup
        UITableView.appearance().backgroundColor = UIColor(backgroundColor2)
    }
    
    var body: some View {
        VStack{
            if groups.count > 0{
                List {
                    ForEach(groups.indices, id:\.self){ inx in
                        let group = groups[inx]
                        HStack{
                            Text(group.timestamp!, formatter: itemFormatter)
                                .foregroundColor(Color.black.opacity(0.5))
                                .font(Font.system(size: 15.0))
                            if !group.isCurrent{
                                NavigationLink {
                                    CounterGroupMini(mode: self.mode, group: group)
                                } label: {
                                    Spacer()
                                    Text("\(group.memo ?? "")")
                                        .foregroundColor(Color.black.opacity(0.3))
                                        .font(Font.system(size: 13.0))
                                    if group.shiny{
                                        Image(systemName: "sparkles")
                                            .foregroundColor(Color.orange)
                                    }
                                }
                            }else{
                                Spacer()
                                Text("\(group.memo ?? "")")
                                    .foregroundColor(Color.black.opacity(0.3))
                                    .font(Font.system(size: 13.0))
                                if group.shiny{
                                    Image(systemName: "sparkles")
                                        .foregroundColor(Color.orange)
                                }
                            }
                        }
                        .frame(height:rulersRowHeight)
                        .deleteDisabled(group.isCurrent)
                    }
                    .onDelete { inx in
                        do{
                            let indexes = inx.map({$0})
                            for i in indexes{
                                viewContext.delete(groups[i])
                            }
                            try viewContext.save()
                            
                            groups.remove(atOffsets: inx)
                        }catch{
                            fatalError(error.localizedDescription)
                        }
                    }
                }
                .background(backgroundColor2)
            }else{
                Text("无历史记录")
                    .foregroundColor(Color.black.opacity(0.3))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 18))
                Spacer()
            }
        }
        .navigationTitle("历史记录")
        .onAppear(){
            self.groups.removeAll()
            
            let dataModel = PMDataModel(dataContext: viewContext)
            self.groups = dataModel.getCounterGroups(mode: self.mode)
            
            for group in self.groups{
                group.isCurrent = group == self.currentGroup
            }
            
            self.groups = self.groups.filter({ group in
                return !group.isCurrent
            })
            
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/M/d HH:mm:ss"
    return formatter
}()


struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(mode: .default7, currentGroup: nil)
    }
}

extension PMCounterGroup{
    private struct AssociatedKey {
        static var shiny: Bool = false
        static var isCurrent: Bool = false
    }
    
    var shiny: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.shiny) as? Bool ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.shiny, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    var isCurrent: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.isCurrent) as? Bool ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.isCurrent, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
