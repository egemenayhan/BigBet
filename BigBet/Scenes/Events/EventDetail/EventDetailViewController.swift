//
//  EventDetailViewController.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//


import UIKit
import RxSwift
import RxCocoa

class EventDetailViewController: UIViewController {

    private let eventCardView = EventCardView()
    private let disposeBag = DisposeBag()

    let viewModel: EventDetailViewModel

    init(viewModel: EventDetailViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupCardViewObservation()
        configureCardView(selectedOddIndex: viewModel.selectedOddIndex.value)
    }

    private func setupViews() {
        view.backgroundColor = ThemeManager.current.background

        eventCardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(eventCardView)

        NSLayoutConstraint.activate([
            eventCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            eventCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            eventCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            eventCardView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func configureCardView(selectedOddIndex: Int?) {
        eventCardView.configure(with: viewModel.event, selectedIndex: selectedOddIndex)
    }

    private func setupCardViewObservation() {
        viewModel.selectedOddIndex
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                self?.configureCardView(selectedOddIndex: index)
            })
            .disposed(by: disposeBag)

        eventCardView.onOddTapped = { [weak self] tappedIndex in
            guard let self, let index = tappedIndex else {
                self?.viewModel.removeBet()
                return
            }
            self.viewModel.placeBet(oddIndex: index)
        }
    }
}
