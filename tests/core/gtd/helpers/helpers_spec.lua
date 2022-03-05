---@diagnostic disable: undefined-global
require("tests.config")

-- Import module
local helpers = neorg.modules.get_module("core.gtd.helpers")

describe("CORE.GTD.HELPERS", function()
    it("get_gtd_excluded_files returns the correct files", function()
        local expected = { "test_file_2.norg" }

        local actual = helpers.get_gtd_excluded_files()

        assert.same(expected, actual)
    end)
    it("get_gtd_files returns the correct files", function()
        local expected = { "inbox.norg", "index.norg", "test_file.norg" }

        local actual = helpers.get_gtd_files()

        assert.same(expected, actual)
    end)
    it("get_gtd_files returns the correct files with no_exclude set", function()
        local expected = { "inbox.norg", "index.norg", "test_file.norg", "test_file_2.norg" }

        local actual = helpers.get_gtd_files({ no_exclude = true })

        assert.same(expected, actual)
    end)
    ---@class core.gtd.queries.task
    ---@field inbox boolean
    ---@field content string
    ---@field type string
    ---@field project? string
    ---@field state string
    ---@field contexts? string[]
    ---@field waiting.for? string[]
    ---@field time.start? string[]
    ---@field time.due? string[]
    ---@field area_of_focus? string
    ---@field internal? core.gtd.queries.task.internal
    ---@field external? table

    ---@class core.gtd.queries.project
    ---@field inbox boolean
    ---@field content string
    ---@field type string
    ---@field area_of_focus? string
    ---@field contexts? string[]
    ---@field waiting.for? string[]
    ---@field time.start? string[]
    ---@field time.due? string[]
    ---@field internal? core.gtd.queries.project.internal
    ---@field external? table
    describe("is_processed", function()
        describe("task", function()
            it("returns false if data.inbox", function()
                local data = { type = "task", inbox = true }
                local actual = helpers.is_processed(data)

                assert.equal(false, actual)
            end)
            it("returns false if type(data.contexts) ~= table", function()
                local data = { type = "task", contexts = "not a table" }
                local actual = helpers.is_processed(data)

                assert.equal(false, actual)
            end)
            it("returns false if data.contexts is an empty table", function()
                local data = { type = "task", contexts = {} }
                local actual = helpers.is_processed(data)

                assert.equal(false, actual)
            end)
            it("returns false if type(data['waiting.for']) ~= table", function()
                local data = { type = "task", contexts = {}, ["waiting.for"] = "not a table" }
                local actual = helpers.is_processed(data)

                assert.equal(false, actual)
            end)
            it("returns false if data['waiting.for'] is an empty table", function()
                local data = { type = "task", contexts = {}, ["waiting.for"] = {} }
                local actual = helpers.is_processed(data)

                assert.equal(false, actual)
            end)
            it("returns false if data['time.due'] is not a table", function()
                local data = { type = "task", inbox = true, ["time.due"] = "not a table" }
                local actual = helpers.is_processed(data)

                assert.equal(false, actual)
            end)
            it("returns false if data['time.due'] is an empty table", function()
                local data = { type = "task", inbox = true, ["time.due"] = {} }
                local actual = helpers.is_processed(data)

                assert.equal(false, actual)
            end)
            it("returns false if data['time.start'] is not a table", function()
                local data = { type = "task", inbox = true, ["time.start"] = "not a table" }
                local actual = helpers.is_processed(data)

                assert.equal(false, actual)
            end)
            it("returns false if data['time.start'] is an empty table", function()
                local data = { type = "task", inbox = true, ["time.start"] = {} }
                local actual = helpers.is_processed(data)

                assert.equal(false, actual)
            end)
        end)
        describe("project", function()
            it("returns nil if tasks is not passed in as an argument", function()
                local data = { type = "project" }
                local actual = helpers.is_processed(data)

                assert.equal(nil, actual)
            end)
            it("returns true if project is in someday", function()
                local data = { type = "project", contexts = { "someday" } }
                local actual = helpers.is_processed(data, { _ = "" })

                assert.equal(true, actual)
            end)
            it("returns false if someday and has unprocessed inbox", function()
                local data = { type = "project", contexts = { someday = "" }, inbox = {} }
                local actual = helpers.is_processed(data, { _ = "" })

                assert.equal(false, actual)
            end)
            it("returns false if empty projects are unprocessed", function()
                local data = { type = "project", uuid = 2, contexts = {} }
                local tasks = { { project_uuid = 1 } }
                local actual = helpers.is_processed(data, tasks)

                assert.equal(false, actual)
            end)
            it("returns true if project_tasks is empty", function()
                local data = { type = "project", uuid = 2, contexts = {} }
                local tasks = { { state = "not done", project_uuid = 2 }, { state = "done", project_uuid = 2 } }
                local actual = helpers.is_processed(data, tasks)

                assert.equal(true, actual)
            end)
            it("returns false if all tasks are proccessed", function()
                local data = { type = "project", uuid = 2, contexts = {} }
                local tasks = { { state = "done", project_uuid = 2 }, { state = "done", project_uuid = 2 } }
                local actual = helpers.is_processed(data, tasks)

                assert.equal(false, actual)
            end)
        end)
    end)
    describe("state_to_text", function()
        it("done", function()
            local expected = "- [x]"
            local input = "done"

            local actual = helpers.state_to_text(input)

            assert.equal(expected, actual)
        end)
        it("undone", function()
            local expected = "- [ ]"
            local input = "undone"

            local actual = helpers.state_to_text(input)

            assert.equal(expected, actual)
        end)
        it("pending", function()
            local expected = "- [-]"
            local input = "pending"

            local actual = helpers.state_to_text(input)

            assert.equal(expected, actual)
        end)
        it("uncertain", function()
            local expected = "- [?]"
            local input = "uncertain"

            local actual = helpers.state_to_text(input)

            assert.equal(expected, actual)
        end)
        it("urgent", function()
            local expected = "- [!]"
            local input = "urgent"

            local actual = helpers.state_to_text(input)

            assert.equal(expected, actual)
        end)
        it("recurring", function()
            local expected = "- [+]"
            local input = "recurring"

            local actual = helpers.state_to_text(input)

            assert.equal(expected, actual)
        end)
        it("onhold", function()
            local expected = "- [=]"
            local input = "onhold"

            local actual = helpers.state_to_text(input)

            assert.equal(expected, actual)
        end)
        it("cancelled", function()
            local expected = "- [_]"
            local input = "cancelled"

            local actual = helpers.state_to_text(input)

            assert.equal(expected, actual)
        end)
    end)
end)
