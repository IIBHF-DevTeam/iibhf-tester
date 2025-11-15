-- Types used by IIBHFTester
--!strict

export type Test = {
    TestName: string,
    TestFunc: (Test) -> (),
    CondToSkip: (Test) -> boolean
}

export type IIBHFServerTester = {
    TestSuiteName: string,
    Tests: {Test},
    RunOutsideOfStudio: boolean,
    OnTestEndWithFail: () -> (),
    OnTestEndWithoutFail: () -> ()
}

export type IIBHFClientTester = {
    PlayerObject: Player,
    TestSuiteName: string,
    Tests: {Test},
    RunOutsideOfStudio: boolean,
    OnTestEndWithFail: () -> (),
    OnTestEndWithoutFail: () -> ()
}