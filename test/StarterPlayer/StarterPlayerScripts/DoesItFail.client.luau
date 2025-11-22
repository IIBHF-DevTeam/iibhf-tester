local Repstore = game:GetService("ReplicatedStorage")
local Tester = require(Repstore.Packages["iibhf-tester"])

local exTest = Tester.NewServerTester("Example", false, function() print("Oh no! My test! It broken!") end, function() print("how....") end)
local foo = Tester.NewServerTest(exTest, "foo", function() return 3*4==12 end, nil)
local bar = Tester.NewServerTest(exTest, "bar", function() return 44+44==32498 end, nil)
Tester.StartServerTestSuite(exTest)