//
//  StatsViewController.swift
//  HousekeepingBook
//
//  Created by 박지승 on 2020/01/13.
//  Copyright © 2020 Jisng. All rights reserved.
//

import UIKit

// tab-bar-tag-2: 통계 컨트롤러
class StatsViewController: UIViewController {
    
    private let infoText = UILabel()
    private let presentCostView = UIView()
    private let presentCostText = UILabel()
    private let guideLine = UILabel()
    private let scrollView = UIScrollView()
    private let tagListView = UITableView()
    private var textAutolayout: NSLayoutConstraint!
    
    // MARK: - <TagData> 넣는 곳
    private var tagData: [String: Int] = [:]
    private var tagArray: [(tag: String, price: Int)] = []
    private var itemViewArr = [UIView]()
    private var presentCost: Int = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let finalCost = formatter.string(from: presentCost as NSNumber)
            presentCostText.text = finalCost
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        baseUI()
        layout()
//        makeCostByTag(data: tagData)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animation()
        setData()
        tagListView.reloadData()
    }
    
    func setData() {
        
        tagData.removeAll()
        tagArray.removeAll()
        
            var tempCost = 0
            let date = Date()
            let count = DataPicker.shared.howManyDaysInMonth(date: date) ?? 0
//            print("카운트 : ", count)
            guard let month = Int(DataPicker.shared.setFormatter(date: date, format: "MM")) else {
                print("year Error")
                return }
            guard let year = Int(DataPicker.shared.setFormatter(date: date, format: "yyyy")) else {
                print("month Error")
                return }
            
            let calendar = Calendar(identifier: .gregorian)
            for i in 1...count {
//                print(year, month, i)
                let compornent = DateComponents(calendar: calendar, year: year, month: month, day: i)
                print(compornent.date)
                guard let date = compornent.date else {
                    print("dateCompornents Error")
                    return}
                let datas = DataPicker.shared.getData(date: date)
                for data in datas {
                    print(data)
                    if let currentPrice = tagData[data.tag] {
                        tagData[data.tag] = currentPrice + data.price
                        
                    }else {
                        tagData[data.tag] = data.price
                    }
                }
                
            }
            
        print(tagData)
        
        for (key, value) in tagData {
            tagArray.append((key, value))
            tempCost += value
        }
        tagArray.sort(by: {$0.price > $1.price})
        
        presentCost = tempCost
        print(tagArray)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        for item in itemViewArr {
            item.layer.cornerRadius = item.frame.width / 2
            
        }
    }
    
    
    func setStats() {
        
        
    }
    
    
    
    private func baseUI() {
        infoText.text = "현재까지 사용 금액입니다."
        infoText.tintColor = ColorZip.midiumGray
        infoText.font = .systemFont(ofSize: 15, weight: .light)
        
        // MARK: - <<이번 달 총액 넣는 곳>>
        presentCostText.text = "100000"
        presentCostText.tintColor = .black
        presentCostText.font = .systemFont(ofSize: 40, weight: .heavy)
        presentCostText.textAlignment = .center
        presentCostText.alpha = 0.0
        
        guideLine.backgroundColor = MyColors.yellow
        
//        scrollView.backgroundColor = .white
        
        view.addSubview(presentCostView)
        presentCostView.addSubview(presentCostText)
        presentCostView.addSubview(infoText)
        view.addSubview(guideLine)
//        view.addSubview(scrollView)
        view.addSubview(tagListView)
        tagListView.dataSource = self
        tagListView.delegate = self
        tagListView.rowHeight = 80
        tagListView.register(StatsCell.self, forCellReuseIdentifier: "Cell")
        tagListView.separatorStyle = .none
    }
    
    
    private func layout() {
        infoText.translatesAutoresizingMaskIntoConstraints = false
        presentCostView.translatesAutoresizingMaskIntoConstraints = false
        presentCostText.translatesAutoresizingMaskIntoConstraints = false
        guideLine.translatesAutoresizingMaskIntoConstraints = false
        tagListView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeLayout = view.safeAreaLayoutGuide
        
        presentCostView.topAnchor.constraint(equalTo: safeLayout.topAnchor).isActive = true
        presentCostView.heightAnchor.constraint(equalTo: safeLayout.heightAnchor, multiplier: 0.2).isActive = true
        presentCostView.leadingAnchor.constraint(equalTo: safeLayout.leadingAnchor).isActive = true
        presentCostView.trailingAnchor.constraint(equalTo: safeLayout.trailingAnchor).isActive = true
        
        infoText.topAnchor.constraint(equalTo: presentCostView.topAnchor, constant: 30).isActive = true
        infoText.centerXAnchor.constraint(equalTo: presentCostView.centerXAnchor).isActive = true
        
        guideLine.topAnchor.constraint(equalTo: presentCostView.bottomAnchor).isActive = true
        guideLine.widthAnchor.constraint(equalTo: safeLayout.widthAnchor, multiplier: 0.8).isActive = true
        guideLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
        guideLine.centerXAnchor.constraint(equalTo: safeLayout.centerXAnchor).isActive = true
        
        presentCostText.centerXAnchor.constraint(equalTo: presentCostView.centerXAnchor).isActive = true
        textAutolayout = presentCostText.topAnchor.constraint(equalTo: guideLine.bottomAnchor)
        textAutolayout.isActive = true
        
        tagListView.topAnchor.constraint(equalTo: guideLine.bottomAnchor).isActive = true
        tagListView.leadingAnchor.constraint(equalTo: safeLayout.leadingAnchor).isActive = true
        tagListView.trailingAnchor.constraint(equalTo: safeLayout.trailingAnchor).isActive = true
        tagListView.bottomAnchor.constraint(equalTo: safeLayout.bottomAnchor).isActive = true
    }
    
    private func animation() {
        UIView.animate(withDuration: 0) {
            self.presentCostText.alpha = 0.0
            self.textAutolayout.constant = CGFloat(0)
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 1) {
            self.presentCostText.alpha = 1.0
            self.textAutolayout.constant = CGFloat(-60)
            self.view.layoutIfNeeded()
        }
    }
    
    private func makeCostByTag(data: [String:Int]) {
        let dataSorted = tagData.sorted { $0.1 > $1.1 }
        var itemIndex = 0
        for (tag, price) in dataSorted {
            let titleTag = UILabel()
            titleTag.text = tag
            let titlePrice = UILabel()
            titlePrice.text = "\(price)"
            
            let circle = UIView()
            circle.backgroundColor = MyColors.yellow
            scrollView.addSubview(circle)
            circle.addSubview(titleTag)
            circle.addSubview(titlePrice)
            
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
            
            titleTag.translatesAutoresizingMaskIntoConstraints = false
            titleTag.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
            titleTag.bottomAnchor.constraint(equalTo: circle.centerYAnchor, constant: -10).isActive = true
            
            titlePrice.translatesAutoresizingMaskIntoConstraints = false
            titlePrice.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
            titlePrice.topAnchor.constraint(equalTo: circle.centerYAnchor, constant: 10).isActive = true
            
            if itemViewArr.isEmpty {
                circle.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20).isActive = true
                circle.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.7).isActive = true
                circle.heightAnchor.constraint(equalTo: circle.widthAnchor).isActive = true
            } else {
                circle.topAnchor.constraint(equalTo: itemViewArr[itemIndex].bottomAnchor, constant: 10).isActive = true
                circle.widthAnchor.constraint(equalTo: itemViewArr[itemIndex].widthAnchor, multiplier: 0.7).isActive = true
                circle.heightAnchor.constraint(equalTo: circle.widthAnchor).isActive = true
                itemIndex += 1
            }
            
            itemViewArr.append(circle)
            
        }
        scrollView.bottomAnchor.constraint(equalTo: itemViewArr[itemViewArr.count-1].bottomAnchor, constant: 20).isActive = true
    }
}


extension StatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tagArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StatsCell
        let data = tagArray[indexPath.row]
        let color = TagData.tags[data.tag]?.color
        let tagName = TagData.tags[data.tag]?.name
        let price = data.price
        let percent = CGFloat(data.price) / CGFloat(presentCost)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let priceText = formatter.string(from: price as NSNumber)
        
//        print("Cell -> ", percent * 100 )
        cell.percent = percent
        cell.tagView.backgroundColor = color
        cell.tagLabel.text = tagName
        cell.priceLabel.text = priceText
        cell.guageView.backgroundColor = color
        
        return cell
    }
    
    
}

extension StatsViewController: UITableViewDelegate {
    
    
    
    
}
