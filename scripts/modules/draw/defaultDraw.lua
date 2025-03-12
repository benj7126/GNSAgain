return function (self)
    getmetatable(self).draw(self)
    for _, elm in pairs(self.elements) do elm:draw() end
end