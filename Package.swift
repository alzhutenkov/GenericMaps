// swift-tools-version:5.3

import Foundation
import PackageDescription

enum Constants {
	static let supportedPlatforms: [SupportedPlatform] = [.iOS(.v13)]
	
	// Основной пакет
	static let configName = "PackageConfig.json"
	static let packageName = "GenericMaps"
	static let testPackageName = "GenericMapsTests"

	/// Если только один тип карты, тогда будет такой макрос
	static let onlyOneMapDefine = "ONLYONEMAP"

	// MARK: - 2gis
	static let dGisPackageName = "DGis"

	// MARK: - apple
	static let appleMapsPackageName = "AppleMaps"

}

/// Типы всех возможных карт
enum MapType: String, CaseIterable, Decodable {
	case dgisMaps = "DGISMAPS"
	case appleMaps = "APPLEMAPS"

	var packageName: String {
		switch self {
		case .dgisMaps: return Constants.dGisPackageName
		case .appleMaps: return Constants.appleMapsPackageName
		}
	}

	var target: Target? {
		switch self {
		case .dgisMaps:
			return .binaryTarget(
				name: Constants.dGisPackageName,
				url: "https://zhutenkov.com/sdk/dgis_1.6.16/DGisFullSDK.zip",
				checksum: "ff889232a28e15682a98f67c4dca303c52aa5f351f92a5fcedd476c5d8f90bd6")
		case .appleMaps:
			return nil
		}
	}

	var sourcePath: String? {
		switch self {
		case .dgisMaps:
			return "Maps/DGis"
		case .appleMaps:
			return "Maps/AMap"
		}
	}
}

/// Все возможные таргеты, относительно возможных типов карт
let targets = makeTargets(with: DataAccessor.mapTypes)

/// Основной пакет
let package = Package(
	name: Constants.packageName,
	platforms: [.iOS(.v13)],
	products: [
		.library(
			name: Constants.packageName,
			type: .dynamic,
			targets: targets.map({$0.name})
		)
	],
	dependencies: [],
	targets: targets
)

func makeTargets(with types: [MapType]) -> [Target] {
	let dependeciesTargets = types.compactMap({$0.target})
	var defines: [String] = types.map({$0.rawValue})
	if defines.count == 1 {
		defines.append(Constants.onlyOneMapDefine)
	}

	var allSources = Set(MapType.allCases.compactMap({$0.sourcePath}))
	let availableSources = types.compactMap({$0.sourcePath})
	for source in availableSources {
		allSources.remove(source)
	}

	var list: [Target] = []
	list.append(.target(
		name: Constants.packageName,
		dependencies: dependeciesTargets.map({Target.Dependency(stringLiteral: $0.name)}),
		exclude: Array(allSources),
		resources: [],
		swiftSettings: defines.map({SwiftSetting.define($0)})
	))
	list.append(contentsOf: dependeciesTargets)
	return list
}

/// Конфиг структуры данных для парсинга
struct PackageConfig: Decodable {
	let maps: [MapType]
}

/// Акцессор для получения данных, не важно от куда
enum DataAccessor {
	// MARK: - Чтение конфига
	static var config: PackageConfig? {
		let packageRootPath = URL(fileURLWithPath: #file)
			.pathComponents
			.dropLast()
			.joined(separator: "/")
			.dropFirst() + "/" + Constants.configName
		let configURL = URL(fileURLWithPath: packageRootPath)
		do {
			let decoder = JSONDecoder()
			let data = try Data(contentsOf: configURL)
			let config = try decoder.decode(PackageConfig.self, from: data)
			return config
		} catch let error {
			print("error: \(error)")
		}

		return nil
	}

	static var mapTypes: [MapType] {
//		config?.maps ?? []
		[.dgisMaps]
	}
}
