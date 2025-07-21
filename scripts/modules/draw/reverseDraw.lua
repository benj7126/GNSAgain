return function (self)
    -- scissor.enter(self.es.x, self.es.y, self.es.w, self.es.h)
    for _, elm in pairs(self.elements) do elm:draw() end
    getmetatable(self).draw(self)
    -- scissor.exit()
end