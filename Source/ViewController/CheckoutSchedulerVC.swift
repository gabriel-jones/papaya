//
//  CheckoutSchedulerVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 2/4/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import Mandoline
import RxSwift

class DayCell: UICollectionViewCell {
    
    static let cellSize = CGSize(width: 90, height: 100)

    let dayLabel = UILabel()
    let dateLabel = UILabel()
    
    var viewModel: DayCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            dayLabel.text = viewModel.dayLabelText?.uppercased()
            dateLabel.text = viewModel.dateLabelText
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        contentView.layer.borderWidth = 1.0
        
        dayLabel.font = Font.gotham(size: 12)
        contentView.addSubview(dayLabel)
        dayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }
        
        dateLabel.font = Font.gotham(size: 18)
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(dayLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DayCellViewModel: Selectable {
    
    let threeLetterWeekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    var date: Date? {
        didSet {
            guard let date = date else { return }
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .ordinal
            dateLabelText = numberFormatter.string(from:  Calendar.current.component(.day, from: date) as NSNumber)
            dayLabelText = threeLetterWeekdayFormatter.string(from: date)
        }
    }
    
    var dayLabelText: String?
    var dateLabelText: String?
    
    var isSelectable: Bool
    
    init(isSelectable: Bool) {
        self.isSelectable = isSelectable
    }
}

class TimeCell: UICollectionViewCell {
    
    static let cellSize = CGSize(width: 90, height: 100)
    
    let timeLabel = UILabel()
    
    var viewModel: TimeCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            timeLabel.text = viewModel.time1! + "\n" + "to" + "\n" + viewModel.time2!
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        contentView.layer.borderWidth = 1.0
        
        timeLabel.font = Font.gotham(size: 14)
        timeLabel.numberOfLines = 0
        timeLabel.textAlignment = .center
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TimeCellViewModel: Selectable {
    
    
    let hourDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "h a"
        return formatter
    }()
    
    var date: Date? {
        didSet {
            guard let date = date else { return }
            time1 = hourDateFormatter.string(from: date)
            time2 = hourDateFormatter.string(from: Calendar.current.date(byAdding: .hour, value: 1, to: date)!)
        }
    }
    
    var time1: String?
    var time2: String?
    
    var isSelectable: Bool
    
    init(isSelectable: Bool) {
        self.isSelectable = isSelectable
    }
}

class CheckoutSchedulerViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let toolbar = UIView()
    private let toolbarBorder = UIView()
    private let scheduleButton = LoadingButton()
    private var closeButton: UIBarButtonItem?
    
    public var checkout: Checkout!
    public var isModal: Bool = false
    
    private let dayModel = PickerDayModel()
    private let timeModel = PickerTimeModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationItem.title = "Schedule Order"
        
        toolbar.backgroundColor = UIColorFromRGB(0xf7f7f7)
        view.addSubview(toolbar)
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
        view.addSubview(tableView)
        
        toolbarBorder.backgroundColor = UIColor(red: 0.796, green: 0.796, blue: 0.812, alpha: 1.0)
        toolbar.addSubview(toolbarBorder)
        
        scheduleButton.backgroundColor = UIColor(named: .green)
        scheduleButton.layer.cornerRadius = 5
        let day = "Friday" // TODO: dyanmic
        scheduleButton.setTitle("Schedule for \(day)", for: .normal)
        scheduleButton.titleLabel?.textColor = .white
        scheduleButton.titleLabel?.font = Font.gotham(size: 17)
        scheduleButton.addTarget(self, action: #selector(schedule(_:)), for: .touchUpInside)
        toolbar.addSubview(scheduleButton)
        
        if isModal {
            closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close").tintable, style: .done, target: self, action: #selector(close(_:)))
            navigationItem.leftBarButtonItem = closeButton
            
            navigationController?.navigationBar.backgroundColor = .white
            
            navigationItem.title = "Friday 24th at 1pm - 2pm"
        }
    }
    
    @objc private func close(_ sender: UIBarButtonItem?) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func schedule(_ sender: LoadingButton) {
        sender.showLoading()
        Request.shared.updateCheckout(orderDate: Date()) // TODO
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { _ in
            sender.hideLoading()
            if self.isModal {
                self.navigationController?.dismiss(animated: true, completion: nil)
                return
            }
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
            let vc = CheckoutViewController()
            vc.checkout = self.checkout
            self.navigationController?.pushViewController(vc, animated: true)
        }, onError: { error in
            print("ERROR HANDLE")
        })
        .disposed(by: disposeBag)
    }
    
    private func buildConstraints() {
        toolbar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(60)
        }
        
        toolbarBorder.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.33)
        }
        
        scheduleButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(toolbar.snp.top)
        }
    }
}

extension CheckoutSchedulerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        switch indexPath.row {
        case 0:
            let pickerView = PickerView()
            pickerView.register(cellType: DayCell.self)
            pickerView.backgroundColor = .clear
            pickerView.dataSource = dayModel
            pickerView.delegate = dayModel
            pickerView.cellSize = DayCell.cellSize
            pickerView.selectedOverlayColor = UIColor(named: .green)
            
            cell.addSubview(pickerView)
            pickerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(DayCell.cellSize.height)
            }
        case 1:
            let pickerView = PickerView()
            pickerView.register(cellType: TimeCell.self)
            pickerView.backgroundColor = .clear
            pickerView.dataSource = timeModel
            pickerView.delegate = timeModel
            pickerView.cellSize = TimeCell.cellSize
            pickerView.selectedOverlayColor = UIColor(named: .green)
            
            cell.addSubview(pickerView)
            pickerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(TimeCell.cellSize.height)
            }
        default: break
        }
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.separatorInset.left = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if isModal {
            return nil
        }
        return "\nOrder on Friday 24th at 1pm - 2pm\n"
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let v = view as? UITableViewHeaderFooterView {
            v.textLabel?.font = Font.gotham(size: 16)
            v.textLabel?.textAlignment = .center
        }
    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let label = UILabel()
//        label.font = Font.gotham(size: 15)
//        label.text = "Order on Friday 24th at 1pm - 2pm"
//        label.textAlignment = .center
//
//        return label
//    }
}

class PickerDayModel: PickerViewDataSource, PickerViewDelegate {
    var selectableCells: [Selectable] {
        let today = Date()
        return (0...8).map { i in
            let cellViewModel = DayCellViewModel(isSelectable: true)
            cellViewModel.date = Calendar.current.date(byAdding: .day, value: i, to: today)
            return cellViewModel
        }
    }
    
    
    func configure(cell: UICollectionViewCell, for: IndexPath) {
        guard let datedCell = cell as? DayCell else { return }
        datedCell.viewModel = selectableCells[`for`.row] as? DayCellViewModel
    }
}

class PickerTimeModel: PickerViewDataSource, PickerViewDelegate {
    var selectableCells: [Selectable] {
        let today = Date()
        return (0...8).map { i in
            let cellViewModel = TimeCellViewModel(isSelectable: true)
            cellViewModel.date = Date()
            return cellViewModel
        }
    }
    
    func configure(cell: UICollectionViewCell, for: IndexPath) {
        guard let datedCell = cell as? TimeCell else { return }
        datedCell.viewModel = selectableCells[`for`.row] as? TimeCellViewModel
    }
}
