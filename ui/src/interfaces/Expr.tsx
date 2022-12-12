import React from "react";

export interface Expr {
    type: ExprType;
    expr: FracExpr | InputExpr;
}

export interface FracExpr {
    n: Expr[];
    d: Expr[];
}

export interface InputExpr {
    value: string;
    ref: React.RefObject<HTMLInputElement>;
}

export enum ExprPos {
    Normal,
    Numerator,
    Denominator,
}

export enum ExprType {
    Frac,
    Input,
}
