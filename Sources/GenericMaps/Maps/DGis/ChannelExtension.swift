//
//  ChannelExtension.swift
//  Maps
//
//  Created by Artem Kislitsyn on 07.05.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

import DGis
import Foundation

// MARK: Channel extension
extension Channel {

	/// Подписка на канал в главном потоке
	///
	/// - Parameter receiveValue: Блок получения данных
	/// - Returns: Объект подписки
	public func sinkOnMainThread(receiveValue: @escaping (Value) -> Void) -> Cancellable {
		sink { value in
			DispatchQueue.main.async {
				receiveValue(value)
			}
		}
	}
}

// MARK: Future extension
extension Future {

	/// Подписка на канал в главном потоке
	///
	/// - Parameters:
	///   - receiveValue: Блок получения данных
	///   - failure: Блок ошибки
	/// - Returns: Объект подписки
	public func sinkOnMainThread(receiveValue: @escaping (Value) -> Void,
								 failure: @escaping (Future<Value>.Error) -> Void) -> Cancellable {
		let successBlock: (Value) -> Void = { value in
			DispatchQueue.main.async {
				receiveValue(value)
			}
		}

		let failureBlock: (DGis.Future<Value>.Error) -> Void = { value in
			DispatchQueue.main.async {
				failure(value)
			}
		}
		return sink(receiveValue: successBlock, failure: failureBlock)
	}
}
