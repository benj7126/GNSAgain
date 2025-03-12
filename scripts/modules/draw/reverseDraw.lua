return function (self)
    for _, elm in pairs(self.elements) do elm:draw() end
    getmetatable(self).draw(self)
end