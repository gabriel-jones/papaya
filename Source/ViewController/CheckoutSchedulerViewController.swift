//
//  CheckoutSchedulerVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 2/4/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation
import Mandoline

//formatter.timeZone = TimeZone(secondsFromGMT: 0)

class DayCell: UICollectionViewCell {
    
    static let cellSize = CGSize(width: 90, height: 100)
    
    let dayLabel = UILabel()
    let dateLabel = UILabel()
    let closedLabel = UILabel()
    
    var viewModel: DayCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            dayLabel.text = viewModel.dayLabelText?.uppercased()
            dateLabel.text = viewModel.dateLabelText
            dayLabel.alpha = viewModel.isSelectable ? 1 : 0.5
            dateLabel.alpha = viewModel.isSelectable ? 1 : 0.5
            closedLabel.isHidden = viewModel.isSelectable
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
        
        closedLabel.font = Font.gotham(size: 12)
        closedLabel.textAlignment = .center
        closedLabel.text = "CLOSED"
        closedLabel.textColor = UIColor(named: .red)
        contentView.addSubview(closedLabel)
        closedLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(6)
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
        formatter.dateFormat = "h a"
        return formatter
    }()
    
    var date: Date? {
        didSet {
            guard let date = date else { return }
            time1 = hourDateFormatter.string(from: date).lowercased()
            time2 = hourDateFormatter.string(from: Calendar.current.date(byAdding: .hour, value: 1, to: date)!).lowercased()
        }
    }
    
    var time1: String?
    var time2: String?
    
    var isSelectable: Bool
    
    init(isSelectable: Bool) {
        self.isSelectable = isSelectable
    }
}

protocol SchedulerDelegate: class {
    func didUpdateCheckout(new: Checkout)
}

class CheckoutSchedulerViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let toolbar = UIView()
    private let toolbarContentView = UIView()
    private let toolbarBorder = UIView()
    private let scheduleButton = LoadingButton()
    private var closeButton: UIBarButtonItem?
    
    public var checkout: Checkout!
    public var isModal: Bool = false
    public var schedule: [ScheduleDay]!
    public var modalDelegate: SchedulerDelegate?
    private var isAsap = true
    
    private let dayModel = PickerDayModel()
    private let timeModel = PickerTimeModel()
    
    public var selectedDate: Date!
//
//    private func movePickerViewsToSelectedDate() { // Forgive me
//        shouldUpdateTime = false
//        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)), let pickerView = cell.subviews.first(where: { $0 is PickerView }) as? PickerView {
//            if let row = self.schedule.index(where: {
//                extractDateOnly(date: selectedDate) == $0.date
//            }) {
//                let indexPath = IndexPath(row: row, section: 0)
//                pickerView.scrollToCell(at: indexPath)
//                let day = self.schedule[row]
//                timeModel.day = day
//                tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
//                if let timeCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)), let timePickerView = timeCell.subviews.first(where: { $0 is PickerView }) as? PickerView {
//                    var t = day.opensAt
//                    var i = 0
//                    while t < day.closesAt {
//                        if timeIsBetween(time: extractTimeOnly(date: selectedDate), start: extractTimeOnly(date: t)!, end: extractTimeOnly(date: Calendar.current.date(byAdding: .hour, value: 1, to: t)!)!) {
//                            let timeIndexPath = IndexPath(row: i, section: 0)
//                            timePickerView.scrollToCell(at: timeIndexPath)
//                            break
//                        }
//                        i += 1
//                        t = Calendar.current.date(byAdding: .hour, value: 1, to: t)!
//                    }
//                }
//            }
//        }
//        shouldUpdateTime = true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedDate = combine(date: schedule.first!.date, withTime: schedule.first!.opensAt)!

        self.buildViews()
        self.buildConstraints()
        
        dayModel.days = schedule
        dayModel.delegate = self
        timeModel.day = schedule.first!
        timeModel.delegate = self
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationItem.title = "Schedule Order"
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        toolbar.backgroundColor = UIColorFromRGB(0xf7f7f7)
        view.addSubview(toolbar)
        
        toolbar.addSubview(toolbarContentView)
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        view.addSubview(tableView)
        
        toolbarBorder.backgroundColor = UIColor(red: 0.796, green: 0.796, blue: 0.812, alpha: 1.0)
        toolbarContentView.addSubview(toolbarBorder)
        
        scheduleButton.backgroundColor = UIColor(named: .green)
        scheduleButton.layer.cornerRadius = 5
        scheduleButton.titleLabel?.textColor = .white
        scheduleButton.titleLabel?.font = Font.gotham(size: 17)
        scheduleButton.addTarget(self, action: #selector(schedule(_:)), for: .touchUpInside)
        toolbarContentView.addSubview(scheduleButton)
        
        if isModal {
            closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close").tintable, style: .done, target: self, action: #selector(close(_:)))
            navigationItem.leftBarButtonItem = closeButton
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0.01))
            navigationController?.navigationBar.backgroundColor = .white
        }
        
        setButton(to: selectedDate, day: schedule.first!)
        setDetail(to: selectedDate, day: schedule.first!)
    }
    
    func daySuffix(date: Date) -> String {
        let dayOfMonth = Calendar.current.component(.day, from: date)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
    
    private func setButton(to date: Date, day: ScheduleDay) {
        scheduleButton.isEnabled = true
        scheduleButton.alpha = 1
        if isAsap {
            scheduleButton.setTitle("Schedule for ASAP", for: .normal)
            return
        } else if !day.isOpen {
            scheduleButton.setTitle("CLOSED", for: .normal)
            scheduleButton.isEnabled = false
            scheduleButton.alpha = 0.5
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        scheduleButton.setTitle("Schedule for \(formatter.string(from: date))", for: .normal)
    }
    
    private func getDetailString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d"
        var str = formatter.string(from: date) + daySuffix(date: date)
        formatter.dateFormat = " 'at' h a - "
        str += formatter.string(from: date).lowercased()
        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: date)!
        formatter.dateFormat = "h a"
        str += formatter.string(from: nextHour).lowercased()
        return str
    }
    
    private func setDetail(to date: Date, day: ScheduleDay) {
        let str = getDetailString(date: date)
        
        if isModal {
            navigationItem.title = str
        } else {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.footerView(forSection: 1)?.textLabel?.text = "\n" + str + "\n"
            tableView.footerView(forSection: 1)?.sizeToFit()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    @objc private func close(_ sender: UIBarButtonItem?) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "An error occured.", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func schedule(_ sender: LoadingButton) {
        sender.showLoading()
        Request.shared.updateCheckout(isAsap: isAsap) { result in
            if result.value == nil {
                self.showError(message: "Cannot schedule order. Please check your connection and try again.")
                return
            }
            if !self.isAsap {
                self.checkout.startDate = self.selectedDate
                Request.shared.updateCheckout(startDate: self.selectedDate, endDate: self.selectedDate.addingTimeInterval(60 * 60)) { result in
                    sender.hideLoading()
                    switch result {
                    case .success(_):
                        if self.isModal {
                            self.modalDelegate?.didUpdateCheckout(new: self.checkout)
                            self.navigationController?.dismiss(animated: true, completion: nil)
                            return
                        }
                        self.next()
                    case .failure(_):
                        self.showMessage("Can't schedule order", type: .error, options: [
                            .autoHide(true),
                            .hideOnTap(true)
                        ])
                    }
                }
            } else {
                sender.hideLoading()
                self.next()
            }
        }
    }
    
    func next() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
        let vc = CheckoutViewController()
        vc.checkout = self.checkout
        vc.schedule = self.schedule
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func buildConstraints() {
        toolbar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        
        toolbarContentView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            if #available(iOS 11, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        
        toolbarBorder.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.33)
        }
        
        scheduleButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
            make.height.equalTo(49)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(toolbar.snp.top)
        }
    }
    
    @objc private func asapChanged(_ sender: UISwitch) {
        if !User.current!.isExpress {
            sender.isOn = true
        }
        isAsap = sender.isOn
        tableView.reloadData()
        self.setButton(to: self.selectedDate, day: schedule.first!)
    }
}

extension CheckoutSchedulerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CheckoutSchedulerViewController: PickerDayDelegate {
    func didSelect(day: ScheduleDay, date: Date, shouldRefresh: Bool) {
        if shouldRefresh {
            timeModel.day = day
            tableView.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .none)
        }
        
        setButton(to: date, day: day)
        setDetail(to: date, day: day)
        
        selectedDate = date
    }
}

extension CheckoutSchedulerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isAsap {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return User.current!.isExpress ? 1 : 2
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "asapCell")
                cell.selectionStyle = .none
                cell.backgroundColor = .white
                cell.separatorInset.left = 0
                
                cell.textLabel?.text = "ASAP"
                cell.textLabel?.font = Font.gotham(size: cell.textLabel!.font.pointSize)
                
                let switchView = UISwitch()
                switchView.isOn = isAsap
                switchView.addTarget(self, action: #selector(asapChanged(_:)), for: .valueChanged)
                switchView.isUserInteractionEnabled = User.current!.isExpress
                cell.accessoryView = switchView
                return cell
            } else {
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "expressCell")
                cell.selectionStyle = .gray
                cell.backgroundColor = .white
                cell.separatorInset.left = 0
                
                cell.textLabel?.text = "Unlock Express"
                cell.textLabel?.font = Font.gotham(size: cell.textLabel!.font.pointSize)
                
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        }
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            let vc = ExpressViewController()
            vc.isModal = true
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.tintColor = UIColor(named: .green)
            present(nav, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return User.current!.isExpress ? nil : "Scheduled orders are only available to Express members."
        }
        if isModal {
            return nil
        }
        return "\n" + self.getDetailString(date: selectedDate) + "\n"
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if section == 0 {
            return
        }
        if let v = view as? UITableViewHeaderFooterView {
            v.textLabel?.font = Font.gotham(size: 16)
            v.textLabel?.textAlignment = .center
        }
    }
}

protocol PickerDayDelegate: class {
    func didSelect(day: ScheduleDay, date: Date, shouldRefresh: Bool)
}

class PickerDayModel: PickerViewDataSource, PickerViewDelegate {
    var days: [ScheduleDay]!
    var delegate: PickerDayDelegate?
    
    var selectableCells: [Selectable] {
        return days.map { day in
            let cellViewModel = DayCellViewModel(isSelectable: day.isOpen)
            cellViewModel.date = day.date
            return cellViewModel
        }
    }
    
    func configure(cell: UICollectionViewCell, for: IndexPath) {
        guard let datedCell = cell as? DayCell else { return }
        datedCell.viewModel = selectableCells[`for`.row] as? DayCellViewModel
    }
    
    func collectionView(_ view: PickerView, didSelectItemAt indexPath: IndexPath) {
        let day = days[indexPath.row]
        let date = combine(date: day.date, withTime: day.opensAt)!
        delegate?.didSelect(day: day, date: date, shouldRefresh: true)
    }
    
    func didSelect(indexPath: IndexPath) {
        let day = days[indexPath.row]
        let date = combine(date: day.date, withTime: day.opensAt)!
        delegate?.didSelect(day: day, date: date, shouldRefresh: true)
    }
}

func combine(date: Date, withTime time: Date) -> Date? {
    let calendar = Calendar.current
    
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
    
    var mergedComponments = DateComponents()
    mergedComponments.year = dateComponents.year
    mergedComponments.month = dateComponents.month
    mergedComponments.day = dateComponents.day
    mergedComponments.hour = timeComponents.hour
    mergedComponments.minute = timeComponents.minute
    mergedComponments.second = timeComponents.second
    
    return calendar.date(from: mergedComponments)
}

func extractDateOnly(date: Date) -> Date? {
    let calendar = Calendar.current
    
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    
    return calendar.date(from: dateComponents)
}

func extractTimeOnly(date: Date) -> Date? {
    let calendar = Calendar.current
    
    let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: date)

    return calendar.date(from: timeComponents)
}

func timeIsBetween(time: Date?, start: Date, end: Date) -> Bool {
    guard let time = time else {
        return false
    }
    return time >= start && time <= end
}

class PickerTimeModel: PickerViewDataSource, PickerViewDelegate {
    func didSelect(indexPath: IndexPath) {
        let time = Calendar.current.date(byAdding: .hour, value: indexPath.row, to: day.opensAt)!
        let date = combine(date: day.date, withTime: time)!
        delegate?.didSelect(day: day, date: date, shouldRefresh: false)
    }
    
    var day: ScheduleDay!
    var delegate: PickerDayDelegate?

    var selectableCells: [Selectable] {
        var results = [TimeCellViewModel]()
        var t = day.opensAt
        while t < day.closesAt {
            let cellViewModel = TimeCellViewModel(isSelectable: true)
            cellViewModel.date = t
            results.append(cellViewModel)
            t = Calendar.current.date(byAdding: .hour, value: 1, to: t)!
        }
        return results
    }
    
    func configure(cell: UICollectionViewCell, for: IndexPath) {
        guard let datedCell = cell as? TimeCell else { return }
        datedCell.viewModel = selectableCells[`for`.row] as? TimeCellViewModel
    }
}

