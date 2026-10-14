"""Entry point for the Jac portfolio."""

cl {
    import from .portfolio { app as PortfolioApp }

    def:pub app -> JsxElement {
        return <PortfolioApp />;
    }
}
