function output = isstrnum(input)

output = 0;

for i = 0:9
    if strcmp(input,num2str(i))
        output = 1;
        return
    end
end