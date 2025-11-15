-- Main IIBHFTester ModuleScript
--!strict

local IIBHFTester = {}
local RunService = game:GetService("RunService")

export type Test = {
    TestName: string,
    TestFunc: (Test) -> (),
    CondToSkip: (Test) -> boolean
}

export type IIBHFServerTester = {
    TestSuiteName: string,
    Tests: {Test},
    TestFailCount: number,
    RunOutsideOfStudio: boolean,
    OnTestEndWithFail: () -> (),
    OnTestEndWithoutFail: () -> ()
}

export type IIBHFClientTester = {
    PlayerObject: Player,
    TestSuiteName: string,
    Tests: {Test},
    TestFailCount: number,
    RunOutsideOfStudio: boolean,
    OnTestEndWithFail: () -> (),
    OnTestEndWithoutFail: () -> ()
}

function IIBHFTester.new(TestSuiteName: string, RunOutsideOfStudio: boolean, OnTestEndWithFail: () -> (), OnTestEndWithoutFail: () -> ()): any
    if RunService:IsServer() then
        --Make tester object
        local self = {
            TestSuiteName = TestSuiteName,
            Tests = {},
            TestFailCount = 0,
            RunOutsideOfStudio = RunOutsideOfStudio,
            OnTestEndWithFail = OnTestEndWithFail(),
            OnTestEndWithoutFail = OnTestEndWithoutFail()
        }
        return self :: any
    else
        local self = {
            PlayerObject = game:GetService("Players").LocalPlayer,
            TestSuiteName = TestSuiteName,
            Tests = {},
            TestFailCount = 0,
            RunOutsideOfStudio = RunOutsideOfStudio,
            OnTestEndWithFail = OnTestEndWithFail(),
            OnTestEndWithoutFail = OnTestEndWithoutFail()
        }
        return self :: any
    end
end

return IIBHFTester