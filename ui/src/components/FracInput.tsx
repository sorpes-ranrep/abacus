import styled from "styled-components";
import React from "react";
import { Expr, ExprType, FracExpr, InputExpr, ExprPos } from "../interfaces/Expr";
// import { usingTheme } from "./MyTheme";

/*
    Essentially done; Expr[] should work.
    Changes should mostly be to css.
*/

interface RIProps {
    value: string;
    column: number;
    withFrac: boolean;
}

const RegInput = styled.input<RIProps>`
    height: max-content;
    border: none;

    margin: 0px;
    padding: 0px;

    grid-row: ${({withFrac}) => withFrac ? "2 / span 1" : "1 / span 1"};
    grid-column: ${({column}) => column} / span 1;
    align-self: center;

    background: var(--rlm-input-color);
    border-color: ${props => props.theme.colors.border.light};
    backdrop-filter: blur(14px);
    /* Note: backdrop-filter has minimal browser support */

    font-family: var(--rlm-font);
    font-style: normal;

    line-height: 118.75%;
    /* identical to box height */

    text-align: center;
`;

//hack to give extra space with lots of %'s as they are wider than
//other chars
function getPercentPadding(val: string) : number {
    return (val.match(/%/)?.length || 0);
}

//    font-size: ${({depth}) => 16 / Math.pow(1.5, depth)}px;
const TopInput = styled(RegInput)`
    width: ${({value}) => (value.length === 0 ? 1 : value.length * 1.45)
            + getPercentPadding(value)}ch;

    font-weight: 400;
    font-size: 100%;
    letter-spacing: 0.22em;

    color: ${props => props.theme.colors.text.medium};
`;

//    font-size: ${({depth}) => 32 / Math.pow(1.5, depth)}px;
//    color: ${props => props.theme.colors.text.black};
// light-test: #FFFFFF;
// dark-test: #000000;
// color: var(--rlm-theme-mode)-text-black;
const BottomInput = styled(RegInput)`
    width: ${({value}) => (value.length === 0 ? 1 : value.length * 1.35)
            + getPercentPadding(value)}ch;

    font-weight: 500;
    font-size: 100%;
    letter-spacing: 0.04em;

    color: ${props => props.theme.colors.text.black};
`;

interface WProps {
    width: number;
    row: number;
    column: number;
    exprPos: ExprPos;
    hasFrac: boolean;
}

const Wrapper = styled.div<WProps>`
    // width: max-content;
    width: 100%
    height: max-content;
    margin: none;
    padding: none;

    display: grid;
    grid-template-columns: repeat(${({width}) => width}, max-content);
    grid-template-rows: ${({hasFrac}) => hasFrac ? "max-content 6px max-content" : "max-content"};
    gap: 1px;

    grid-row: ${({row}) => row} / span 1;
    grid-column: ${({column}) => column} / span 1;
    justify-self: center;
    align-self: ${({exprPos}) => exprPos === ExprPos.Normal ? "center" : (exprPos === ExprPos.Numerator ? "end" : "start")};

    background: var(--rlm-input-color);
`;

//    background: var(--rlm-input-color);
const Backdrop = styled.div`
    box-sizing: border-box;
    width: 80%;
    height: 100%;
    min-height: 100px;
    padding: 12px;
    margin: 0px auto;

    display: grid;
    grid-template-rows: 1fr 12px max-content;
    grid-template-columns: 1fr 12px max-content;
    gap: 0px;
    justify-items: end;

    border-radius: 9px;
    border: 1px solid  ${props => props.theme.colors.border.light};
    background: var(--rlm-input-color);
    backdrop-filter: blur(14px);
    /* Note: backdrop-filter has minimal browser support */
`;

const TopWrapper = styled.div`
    grid-row: 1;
    grid-column: 3;
    width: max-content;
    height: max-content;
`;

const BottomWrapper = styled.div`
    grid-row: 3;
    grid-column: 3;
    width: max-content;
    height: max-content;
`;

interface InputTypeProps {
    isBottom: boolean;
    innerProps: RIProps;
    onChange: React.ChangeEventHandler<HTMLInputElement>;
    onKeyDown: React.KeyboardEventHandler<HTMLInputElement>;
    onFocus: React.FocusEventHandler<HTMLInputElement>;
    onMouseOut: React.MouseEventHandler<HTMLInputElement>;
    ref: React.ForwardedRef<HTMLInputElement>;
}

const InputType: React.FC<InputTypeProps> = React.forwardRef<HTMLInputElement, InputTypeProps>(
    (props: InputTypeProps, ref: React.ForwardedRef<HTMLInputElement>) => {
    return props.isBottom ? 
        <BottomInput onChange={props.onChange}
                     onFocus={props.onFocus}
                     onMouseOut={props.onMouseOut}
                     onKeyDown={props.onKeyDown}
                    //make undefined unless selected, in which case give name curExpr or curInput
                    //then focus on component did mount
                     ref={ref}
                     spellCheck={false}
                     {...props.innerProps}
                     /> : 
        <TopInput readOnly={true} {...props.innerProps}/>;
});

interface DBProps {
    column: number;
}

const DivBar = styled.div<DBProps>`
    height: 2px;
    width: 100%;

    margin: 0px;
    padding: 0px;

    align-self: center;

    grid-row: 2 / span 1;
    grid-column: ${({column}) => column} / span 1;
`;

const TopDivBar = styled(DivBar)`
    background: ${props => props.theme.colors.text.medium};
`;

const BottomDivBar = styled(DivBar)`
    background: ${props => props.theme.colors.text.black};
`;

interface DivBarTypeProps {
    isBottom: boolean;
    innerProps: DBProps;
}

const DivBarType: React.FC<DivBarTypeProps> = (props: DivBarTypeProps) => {
    return props.isBottom ? <BottomDivBar {...props.innerProps}/> : <TopDivBar {...props.innerProps}/>;
}

interface FPProps {
    row: number;
    column: number;
    selected: boolean;
}

const FracPlaceholder = styled.div<FPProps>`
    background: ${props => props.selected ? 
        props.theme.colors.background.blue :
        props.theme.colors.background.lightAccent};
    border: 1px dashed ${props => props.selected ?
        props.theme.colors.border.blue :
        props.theme.colors.border.lighter};
    // width: 15px;
    // height: 15px;
    width: 100%;
    padding-bottom: 100%;
    min-width: 10px;
    grid-row: ${({row}) => row} / span 1;
    grid-column: ${({column}) => column} / span 1;
    justify-self: center;
`;

function arrayEqual<T>(a: T[], b: T[]) {
    if (a === b) return true;
    if (a == null || b == null) return false;
    if (a.length !== b.length) return false;
  
    for (var i = 0; i < a.length; ++i) {
      if (a[i] !== b[i]) return false;
    }
    return true;
}

function getNestGridsImpl(exprs: Expr[], path: number[], exprPos: ExprPos,
row: number, col: number, isBottom: boolean, props: FracInputProps) : JSX.Element {
    const hasFrac: boolean = exprs.some((value: Expr) => value.type === ExprType.Frac);
    const gridElements: JSX.Element[] = [];
    for(let i = 0; i < exprs.length; i++) {
        const newPath: number[] = Object.assign([], path);
        newPath.push(i);
        if (exprs[i].type === ExprType.Input) {
            gridElements.push(<InputType isBottom={isBottom}
                innerProps={{value: (exprs[i].expr as InputExpr).value, column: i + 1, withFrac: hasFrac}}
                onChange={(e: React.ChangeEvent<HTMLInputElement>) => props.onChange(newPath, e)}
                onKeyDown={props.onKeyDown}
                onFocus={(e: React.FocusEvent<HTMLInputElement>) => props.onFocus(newPath, e)}
                onMouseOut={(e: React.MouseEvent<HTMLInputElement>) => props.onMouseOut(newPath, e)}
                ref={(exprs[i].expr as InputExpr).ref}
                /*
                may need this for cursor/caret position
                onMouseOut={} 
                */
                />);
        } else {
            const frac: FracExpr = exprs[i].expr as FracExpr;
            const nPath: number[] = Object.assign([], newPath);
            const dPath: number[] = Object.assign([], newPath);
            nPath.push(0);
            dPath.push(1);

            //add placeholders here
            if (frac.n.length === 1 && frac.n[0].type === ExprType.Input && (frac.n[0].expr as InputExpr).value === "") {
                nPath.push(0);
                gridElements.push(<FracPlaceholder row={1} column={i+1} 
                    selected={arrayEqual(props.path, nPath)}
                    onClick={(e: React.MouseEvent<HTMLDivElement>) => props.onPlaceholderClick(nPath, e)}/>)
            } else {
                gridElements.push(getNestGridsImpl(frac.n, nPath, ExprPos.Numerator, 1, i+1, isBottom, props));
            }
            gridElements.push(<DivBarType isBottom={isBottom} innerProps={{column: i+1}}/>);
            if (frac.d.length === 1 && frac.d[0].type === ExprType.Input && (frac.d[0].expr as InputExpr).value === "") {
                dPath.push(0);
                gridElements.push(<FracPlaceholder row={3} column={i+1}
                    selected={arrayEqual(props.path, dPath)}
                    onClick={(e: React.MouseEvent<HTMLDivElement>) => props.onPlaceholderClick(dPath, e)}/>)
            } else {
                gridElements.push(getNestGridsImpl(frac.d, dPath, ExprPos.Denominator, 3, i+1, isBottom, props));
            }
        }
    }
    return <Wrapper width={gridElements.length} row={row} column={col}
                exprPos={exprPos} hasFrac={hasFrac}>
                {...gridElements}
            </Wrapper>
}

export interface FracInputProps {
    exprs: Expr[];
    prevExprs: Expr[];
    onChange(path: number[], e: React.ChangeEvent<HTMLInputElement>): void;
    onKeyDown: React.KeyboardEventHandler<HTMLInputElement>;
    onFocus(path: number[], e: React.FocusEvent<HTMLInputElement>): void;
    onPlaceholderClick(path: number[], e: React.MouseEvent<HTMLDivElement>): void;
    onMouseOut(path: number[], e: React.MouseEvent<HTMLInputElement>): void;
    path: number[];
};

const FracInput: React.FC<FracInputProps> = (props: FracInputProps) => {
    return (
        <Backdrop>
            <TopWrapper>
                {getNestGridsImpl(props.prevExprs, [], ExprPos.Normal, 1, 1, false, props)}
            </TopWrapper>
            <BottomWrapper>
                {getNestGridsImpl(props.exprs, [], ExprPos.Normal, 1, 1, true, props)}
            </BottomWrapper>
        </Backdrop>
    )
};

export default FracInput;
