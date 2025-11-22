-- Main IIBHFTester ModuleScript
--!strict

local IIBHFTester = {}
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Promise = require(script.Packages:WaitForChild("promise"))

local Version = " V0.1"

-- Put your game's name here!
local GameName

if game:GetService("ReplicatedStorage"):WaitForChild("IIBHFConfig"):FindFirstChild("GameName") then
    GameName = game:GetService("ReplicatedStorage"):WaitForChild("IIBHFConfig"):FindFirstChild("GameName").Value
else
    GameName = "Game Name Here!"
end

export type ServerTest = {
    TestName: string,
    TestFunc: (ServerTest) -> boolean,
    CondToSkip: (ServerTest) -> boolean
}
export type ClientTest = {
    ClientPlayer: Player,
    TestName: string,
    TestFunc: (ClientTest) -> boolean,
    CondToSkip: (ClientTest) -> boolean
}

export type IIBHFServerTester = {
    TestSuiteName: string,
    Type: string,
    Tests: {ServerTest},
    TestFailCount: number,
    RunOutsideOfStudio: boolean,
    OnTestEndWithFail: () -> (),
    OnTestEndWithoutFail: () -> (),
}

export type IIBHFClientTester = {
    PlayerObject: Player,
    TestSuiteName: string,
    Type: string,
    Tests: {ClientTest},
    TestFailCount: number,
    RunOutsideOfStudio: boolean,
    OnTestEndWithFail: () -> (),
    OnTestEndWithoutFail: () -> ()
}

function IIBHFTester.CanRun(TestSuite: any)
    if not TestSuite.RunOutsideOfStudio then
        return RunService:IsStudio()
    else
        return true
    end
end

function IIBHFTester.StartServerTestSuite(TestSuite: IIBHFServerTester)
    print(typeof(TestSuite)..TestSuite.TestSuiteName)
    if TestSuite.Type ~= "Server" then
        error("IIBHFClientTester was passed in, you need to pass in an IIBHFServerTester")
    end
    if RunService:IsClient() then
        error("Cannot start a server test suite on the client, please use StartClientTestSuite")
    end
    print("Running IIBHF Testing Suite for "..GameName..Version)
    if IIBHFTester.CanRun(TestSuite) then
        local tests = TestSuite.Tests
        for _, test: ServerTest in tests do
            local function promiseFunc(): any
                return Promise.new(function(resolve, reject, onCancel)
                    if not test.CondToSkip(test) then
                        local succeeded = test.TestFunc(test)
                        if not succeeded then
                            TestSuite.TestFailCount += 1
                            resolve(test.TestName.." - FAIL")
                        else
                            resolve(test.TestName.." - PASS")
                        end
                    end
                end)
            end
            promiseFunc():andThen(print):timeout(25):catch(function()
                if Promise.Error.isKind(e, Promise.Error.Kind.TimedOut) then
                    print(test.TestName.."- FAIL(TIMEOUT)")
                else
                    print(test.TestName.."- FAIL(ERR)")
                    warn(HttpService:JSONEncode(e))
                end
            end):await()
        end
        if TestSuite.TestFailCount > 0 then
            TestSuite.OnTestEndWithFail()
        else
            TestSuite.OnTestEndWithoutFail()
        end
    else
        warn("This test suite can only run in studio!")
        return
    end
end

function IIBHFTester.StartClientTestSuite(TestSuite: IIBHFClientTester)
    if TestSuite.Type ~= "Client" then
        error("IIBHFServerTester was passed in, you need to pass in an IIBHFClient Tester")
    end
    if RunService:IsServer() then
        error("Cannot start a client test suite on the server, please use StartServerTestSuite")
    end
    print("Running IIBHF Testing Suite for "..GameName..Version)
    if IIBHFTester.CanRun(TestSuite) then
        local tests = TestSuite.Tests
        for _, test: ClientTest in tests do
            local function promiseFunc(): any
                return Promise.new(function(resolve, reject, onCancel)
                    if not test.CondToSkip(test) then
                        local succeeded = test.TestFunc(test)
                        if not succeeded then
                            TestSuite.TestFailCount += 1
                            resolve(test.TestName.." on client".." - <b>FAIL</b>")
                        else
                            resolve(test.TestName.." on client".." - <b>PASS</b>")
                        end
                    end
                end)
            end
            promiseFunc():andThen(print):timeout(25):catch(function()
                if Promise.Error.isKind(e, Promise.Error.Kind.TimedOut) then
                    print(test.TestName.." on client".."- <b>FAIL(TIMEOUT)</b>")
                else
                    print(test.TestName.." on client".."- <b>FAIL(ERR)</b>")
                end
            end):await()
        end
        if TestSuite.TestFailCount > 0 then
            TestSuite.OnTestEndWithFail()
        else
            TestSuite.OnTestEndWithoutFail()
        end
    else
        warn("This test suite can only run in studio!")
        return
    end
end

-- Makes a new Test Suite
function IIBHFTester.NewServerTester(TestSuiteName: string, RunOutsideOfStudio: boolean, OnTestEndWithFail: () -> (), OnTestEndWithoutFail: () -> ()): IIBHFServerTester
    --Make tester object
    local self: IIBHFServerTester = {
        TestSuiteName = TestSuiteName,
        Type = "Server",
        Tests = {},
        TestFailCount = 0,
        RunOutsideOfStudio = RunOutsideOfStudio,
        OnTestEndWithFail = OnTestEndWithFail,
        OnTestEndWithoutFail = OnTestEndWithoutFail
    }
    return self :: IIBHFServerTester
end

function IIBHFTester.NewClientTester(TestSuiteName: string, RunOutsideOfStudio: boolean, OnTestEndWithFail: () -> (), OnTestEndWithoutFail: () -> ()): IIBHFClientTester
    local self: IIBHFClientTester = {
            PlayerObject = game:GetService("Players").LocalPlayer,
            TestSuiteName = TestSuiteName,
            Type = "Client",
            Tests = {},
            TestFailCount = 0,
            RunOutsideOfStudio = RunOutsideOfStudio,
            OnTestEndWithFail = OnTestEndWithFail,
            OnTestEndWithoutFail = OnTestEndWithoutFail
        }
        return self :: IIBHFClientTester
end

function IIBHFTester.NewServerTest(TestSuite: IIBHFServerTester, TestName: string, TestFunc: (ServerTest) -> boolean, CondToSkip: (ServerTest) -> boolean): ServerTest
    if RunService:IsClient() then
        error("You cannot make a new server test on client, use NewClientTest!")
    end
    if CondToSkip == nil then
        CondToSkip = function(test: ServerTest): boolean return false end
    end
    local test: ServerTest = {
        TestName = TestName,
        TestFunc = TestFunc,
        CondToSkip = CondToSkip,
    }
    table.insert(TestSuite.Tests, test)
    return test
end

function IIBHFTester.NewClientTest(TestSuite: IIBHFClientTester, TestName: string, TestFunc: (ClientTest) -> boolean, CondToSkip: (ClientTest) -> boolean)
    if RunService:IsServer() then
        error("You cannot make a new client test on server, use NewServerTest!")
    end
    if CondToSkip == nil then
        CondToSkip = function(test: ClientTest): boolean return false end
    end
    local test: ClientTest = {
        ClientPlayer = game:GetService("Players").LocalPlayer,
        TestName = TestName,
        TestFunc = TestFunc,
        CondToSkip = CondToSkip
    }
    table.insert(TestSuite.Tests, test)
    return test
end


return IIBHFTester