--[[
    Written by Neptune (Itz_N3p)

pros:
    supports richtext
    automatically formats any text : quotations, brackets, quotation

ex:
    local formattedText, filledRows = scaleText.MaxCharactersPerRow("content!",30)
    formattedText = scaleText.CompressStrWithMinimumRows(formattedText,filledRows,5)
]]

local scaleText = {}

--extra functions, internal use but you can use em if you want
    function scaleText._compressToLength(str:string,maxCharacters)
        return str:sub(1,maxCharacters),str:sub(maxCharacters+1,str:len())
    end

    function scaleText._normalizeToCharactersPerRow(str:string,maxCharacters) --I forgot what this does, I think it just does what the name is tho
        local primary,overflow = scaleText._compressToLength(str,maxCharacters)
        if overflow:len() == 0 then
            return primary,overflow
        else
            local storage = {primary}
            local str = primary.."\n"

            local function tillOverflowIsClear(activeStr)
                local primary, overflow = scaleText._compressToLength(activeStr,maxCharacters)
                str = str..primary.."\n"
                table.insert(storage,primary)
                if overflow:len() ~= 0 then
                    tillOverflowIsClear(overflow)
                end
            end

            tillOverflowIsClear(overflow)
            return str,storage
        end
    end

    function scaleText._splitBySpaces(str:string)
        return str:split(" ")
    end

    function scaleText._removeInvisibleNextLineCharacters(str: string) --removes \n for bracket strings
       return str:gsub("%c", " ")
    end

    function scaleText._splitByRichTextSpaces(str: string)
        local currentTextIndex = 1
        local data = {
            richtext = {},
            normaltext = {}
        }
    
        for i,v in string.split(str, "<") do 
            local split = string.split(v, ">")
            for i,v in split do
                local index = if #split == 2 and i == 1 then "richtext" else "normaltext"
                data[index][currentTextIndex] = v
                currentTextIndex += 1 
            end            
        end
    
        for i,v in data.normaltext do
            data.normaltext[i] = scaleText._splitBySpaces(v)
            local subbed = 0
            for j = 1,#data.normaltext[i] do
                if data.normaltext[i][j] == "" then
                    data.normaltext[i][j] = " "
                elseif data.normaltext[i][j+subbed] and j+subbed ~= #data.normaltext[i] then
                    data.normaltext[i][j+subbed] = data.normaltext[i][j+subbed].." "
                end
            end
        end
    
        return data,currentTextIndex - 1
    end
    
--main functions
    function scaleText.MaxCharactersPerRow(str: string, maxCharacters: number)
        str = scaleText._removeInvisibleNextLineCharacters(str)
        local data,indecies = scaleText._splitByRichTextSpaces(str)
        local newString = ""
        local calculatedLength = 0
        local rows = 1
        for i = 1,indecies do
            if data.normaltext[i] then
                for i,v in data.normaltext[i] do		
                    if v:match("!n") then --custom string that starts a new line
                        calculatedLength = 0
                        newString = newString.."\n"
                        rows += 1
                    elseif v:match("!t") then --custom string that indents a line
                        local info = v:split(v,"!t")
                        newString = newString.."     "..info[2]
                        calculatedLength += 5
                    else
                        if calculatedLength >= maxCharacters then
                            calculatedLength = 0
                            newString = newString.."\n"
                            rows += 1
                        end
                        calculatedLength += v:len()
                        newString = newString..v
                    end		
                end
            else
                newString = newString..string.format("<%s>",data.richtext[i])
            end
        end
        return newString,rows
    end

    function scaleText.CompressStrWithMinimumRows(str: string,currentRows: number,minimumRows: number)
        if currentRows >= minimumRows then
            return str
        else
            repeat
                str = str.."\n"
                currentRows += 1
            until currentRows >= minimumRows
            return str
        end
    end

return scaleText