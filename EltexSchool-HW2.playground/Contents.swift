import Foundation

enum CargoType: Equatable {
    case fragile
    case perishable(temperatureRequirement: Int)
    case bulk
}

struct Cargo {
    let description: String
    let weight: Int
    let type: CargoType
    
    init?(
        description: String,
        weight: Int,
        type: CargoType
    ) {
        guard weight > 0 else { return nil }
        
        self.description = description
        self.weight = weight
        self.type = type
    }
}

class Vehicle {
    let make: String
    let model: String
    let year: Int
    let capacity: Int
    let types: [CargoType]?
    var currentLoad: Int?
    let tankVolume: Int
    
    var loadedCargos: [Cargo] = []
    
    init (
        make: String,
        model: String,
        year: Int,
        capacity: Int,
        types: [CargoType]?,
        currentLoad: Int,
        tankVolume: Int
    ) {
        self.make = make
        self.model = model
        self.year = year
        self.capacity = capacity
        self.types = types
        self.currentLoad = currentLoad
        self.tankVolume = tankVolume
    }
    
    // Метод загрузки груза
    func loadCargo(cargo: Cargo) {
        // Проверка типа груза
        if let types = types,
           !types.contains(where: { $0 == cargo.type }) {
            print("Ошибка: Транспортное средство не поддерживает данный тип груза.")
            return
        }
        
        // Проверка текущей загрузки и грузоподъемности
        guard let currentLoad = currentLoad else {
            print("Ошибка: Невозможно определить текущую нагрузку транспортного средства.")
            return
        }
        
        let newCurrentLoad = currentLoad + cargo.weight
        
        if newCurrentLoad <= capacity {
            self.currentLoad = newCurrentLoad
            loadedCargos.append(cargo)
            
            print("Груз \(cargo.description) успешно загружен! Текущая нагрузка: \(self.currentLoad ?? 0) кг.")
        } else {
            print("Ошибка: Груз \(cargo.description) превышает допустимую грузоподъемность.")
        }
    }
    
    // Метод для отображения информации о транспортном средстве
    func vehicleInfo() {
        print("Транспортное средство: \(make) \(model), \(year) года")
        print("Общая грузоподъемность: \(capacity) кг, текущая загрузка: \(currentLoad ?? 0) кг")
        print("Список загруженных грузов:")
        
        for cargo in loadedCargos {
            print(" - \(cargo.description), вес: \(cargo.weight) кг, тип: \(cargo.type)")
        }
    }
    
    // Метод разгрузки
    func unloadCargo() {
        currentLoad = 0
        loadedCargos.removeAll()
        
        print("Транспортное средство разгружено.")
    }
    
    // Метод для проверки, можно ли отправить указанный груз на указанное расстояние
    func canGo(cargo: [Cargo], path: Int) -> Bool {
        // Общий вес груза
        let totalWeight = cargo.reduce(0) { $0 + $1.weight }
        
        guard totalWeight <= capacity else {
            print("Ошибка: Суммарный вес груза превышает грузоподъемность транспортного средства.")
            return false
        }
        
        // Проверка объема топлива
        let maxDistance = tankVolume / 2
        
        if path > maxDistance {
            print("Ошибка: Недостаточный объем топлива для преодоления указанного расстояния.")
            return false
        }
        
        print("Можно отправить груз на расстояние \(path) км.")
        return true
    }
}

final class Truck: Vehicle {
    let trailerAttached: Bool
    let trailerCapacity: Int?
    let trailerTypes: [CargoType]?
    
    init(
        make: String,
        model: String,
        year: Int,
        capacity: Int,
        types: [CargoType]?,
        currentLoad: Int,
        tankVolume: Int,
        trailerAttached: Bool,
        trailerCapacity: Int?,
        trailerTypes: [CargoType]?
    ) {
        self.trailerAttached = trailerAttached
        self.trailerCapacity = trailerCapacity
        self.trailerTypes = trailerTypes
        
        super .init(
            make: make,
            model: model,
            year: year,
            capacity: capacity,
            types: types,
            currentLoad: currentLoad,
            tankVolume: tankVolume
        )
    }
    
    // Переопределенный метод для загрузки груза с учетом прицепа
    override func loadCargo(cargo: Cargo) {
        // Если есть прицеп, проверяем его грузоподъемность и типы грузов
        if trailerAttached,
           let trailerCapacity = trailerCapacity,
           let currentLoad = currentLoad,
           currentLoad + cargo.weight <= trailerCapacity {
            self.currentLoad = currentLoad + cargo.weight
            loadedCargos.append(cargo)
            
            print("Груз \(cargo.description) успешно загружен в прицеп! Текущая нагрузка прицепа: \(self.currentLoad ?? 0) кг.")
        } else {
            // Используем стандартный метод загрузки транспортного средства
            super.loadCargo(cargo: cargo)
        }
    }
}

final class Fleet {
    private var vehicles: [Vehicle] = []
    
    // Добавить транспортное средство в автопарк
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
    }
    
    func info() {
        print("\nОбщая грузоподъемность: \(totalCapacity()) кг.")
        print("Текущая нагрузка: \(totalCurrentLoad()) кг.")
        print("Список транспортных средств и их загруженные грузы: \n")
        
        for vehicle in vehicles {
            vehicle.vehicleInfo()
        }
    }
    
    // Расчет общей грузоподъемности
    private func totalCapacity() -> Int {
        vehicles.reduce(0) { $0 + $1.capacity }
    }
    
    // Расчет текущей нагрузки
    private func totalCurrentLoad() -> Int {
        vehicles.reduce(0) { $0 + ($1.currentLoad ?? 0) }
    }
}

// Создание грузов
let cargo1 = Cargo(
    description: "Скоропортящиеся продукты",
    weight: 200,
    type: .perishable(temperatureRequirement: 10)
)

let cargo2 = Cargo(
    description: "Хрупкие предметы",
    weight: 100,
    type: .fragile
)

let cargo3 = Cargo(
    description: "Сыпучие материалы",
    weight: 300,
    type: .bulk
)

// Создание транспортных средств
let truck1 = Truck(
    make: "Volvo",
    model: "FH16",
    year: 2020,
    capacity: 1000,
    types: [
        .fragile,
        .perishable(temperatureRequirement: 20)
    ],
    currentLoad: 0,
    tankVolume: 200,
    trailerAttached: true,
    trailerCapacity: 500,
    trailerTypes: [.bulk]
)

let vehicle1 = Vehicle(
    make: "Ford",
    model: "Transit",
    year: 2018,
    capacity: 800,
    types: [.fragile],
    currentLoad: 0,
    tankVolume: 150
)

// Создание автопарка и добавление транспортных средств
let fleet = Fleet()
fleet.addVehicle(truck1)
fleet.addVehicle(vehicle1)

// Загрузка грузов
if let cargo1 = cargo1 {
    truck1.loadCargo(cargo: cargo1)
}

if let cargo2 = cargo2 {
    vehicle1.loadCargo(cargo: cargo2)
}

// Part 1: Информация об автопарке
fleet.info()

print("\n")

// Part 2: Симуляция перевозки груза
if let cargo1 = cargo1 {
    truck1.canGo(cargo: [cargo1], path: 100)
}
