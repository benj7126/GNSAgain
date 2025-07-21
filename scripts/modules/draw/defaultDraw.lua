return function (self)
    --scissor.enter(self.es.x, self.es.y, self.es.w, self.es.h)
    getmetatable(self).draw(self)
    for _, elm in pairs(self.elements) do elm:draw() end
    --scissor.exit()
end