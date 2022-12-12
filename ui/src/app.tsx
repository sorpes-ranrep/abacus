import React from "react";
import styled, { ThemeProvider } from "styled-components";
import { CircleButton } from "./components/CircleButton";
import { ButtonLabel } from "./components/ButtonLabel";
import { AbacusBody } from "./components/AbacusBody";
import { ButtonGrid } from "./components/ButtonGrid";
import { SquareButton } from "./components/SquareButton";
import { Expr, ExprType, InputExpr, FracExpr } from "./interfaces/Expr";
import FracInput/*, { FracInputProps }*/ from "./components/FracInput";
import NumberButton from "./components/NumberButton";

import {lightColors , darkColors} from "./components/MyTheme";

import { UnitTypeDropDown, UnitDropDown, AmountInput, MeasureDiv,
    UnitDropDownStyles, UnitDropDownWrapper, UnitOption, UnitTypeDropDownStyles } from "./components/Convert";

import { ModeButton, ModeButtonsDiv } from "./components/ModeSelector";

import Urbit from "@urbit/http-api";
import { Charges, ChargeUpdateInitial, scryCharges } from "@urbit/api";

const api = new Urbit("", "", window.desk);
api.ship = window.ship;

const theme: AbacusTheme = {
    colors: lightColors,
}

//width: 400px;
    // background: var(--rlm-window-color);
const Page = styled.div`
    width: 100%;
    height: 100%;
    // margin: auto;

    padding: 12px;

    background: var(--rlm-window-color);
    font-family: var(--rlm-font);
    color: var(--rlm-text-color);
`;

const CalcEquals = styled.label`
    font-family: var(--rlm-font);
    font-style: normal;
    font-weight: 400;
    font-size: 25px;
    line-height: 30px;
    /* identical to box height */

    width: max-content;
    text-align: center;
    letter-spacing: 0.04em;
    margin: auto;
    display: block;

    color: ${props => props.theme.colors.text.dark}4C;
`;

//    background: ${props => props.theme.colors.background.dark};
// background: var(--rlm-theme-mode)-background-dark;
const StyledSquareButton = styled(SquareButton)`
    background: ${props => props.theme.colors.background.dark};
`;

//    background: ${props => props.theme.colors.background.dark};
const OpButton = styled(CircleButton)`
    background: ${props => props.theme.colors.background.dark};
`;

const EqualsButton = styled(CircleButton)`
    background: ${(props) => props.theme.colors.background.accent};
`; 

interface Unit {
    name: string,
    symbol: string,
}

interface Answer {
    ans: number;
}

interface ProvidedTheme {
    accentColor: string;
    backgroundColor: string;
    dockColor: string;
    iconColor: string;
    inputColor: string;
    mode: string;
    textColor: string;
    wallpaper: string;
    windowColor: string;
}

interface AbacusTheme {
    colors: any,
    provided?: ProvidedTheme,
}

export interface AppSettings {
    //TODO: subscribe to back-end for these
    theme: AbacusTheme,
    precision: number,
}

export interface AppState {
    apps?: Charges,
    history?: History,
    settings: AppSettings,
    exprs: Expr[],
    prevExprs: Expr[],
    inputPath: number[],
    caretPos: number,
    mode: string,
    unitTypes: string[],
    unitsOfType: Map<string, UnitOption[]>,
    unitType?: string,
    amount1: string,
    amount2: string,
    unit1?: UnitOption,
    unit2?: UnitOption,
    keysDown: string[],
}

export interface AppProps {
    
}

//can probably make dark theme by inverting each color and then overwriting with
//a smaller theme object

export class App extends React.Component<AppProps, AppState> {
  constructor (props: AppProps){
        super(props);
        this.state = {
            exprs: [{type: ExprType.Input, expr: {value: "", ref: React.createRef<HTMLInputElement>()}}],
            prevExprs: [],
            inputPath: [0],
            caretPos: 0,
            settings: {
                theme: theme,
                precision: 6,
            },
            mode: "calculate",
            unitTypes: [],
            unitsOfType: new Map<string, UnitOption[]>(),
            amount1: "",
            amount2: "",
            keysDown: [],
        };

        this.equals = this.equals.bind(this);
        this.handleChange = this.handleChange.bind(this);
        this.buttonInput = this.buttonInput.bind(this);
        this.clear = this.clear.bind(this);
        this.getExpr = this.getExpr.bind(this);
        this.getExprAtPath = this.getExprAtPath.bind(this);
        this.setValAtPath = this.setValAtPath.bind(this);
        this.getExprsCopy = this.getExprsCopy.bind(this);
        this.insertFraction = this.insertFraction.bind(this);
        this.handleFocus = this.handleFocus.bind(this);
        this.calcMode = this.calcMode.bind(this);
        this.convMode = this.convMode.bind(this);
        this.unitTypeChange = this.unitTypeChange.bind(this);
        this.unitChange1 = this.unitChange1.bind(this);
        this.unitChange2 = this.unitChange2.bind(this);
        this.amount1Change = this.amount1Change.bind(this);
        this.amount2Change = this.amount2Change.bind(this);
        this.handlePlaceholderClick = this.handlePlaceholderClick.bind(this);
        this.onMouseOut = this.onMouseOut.bind(this);
        this.onKeyDown = this.onKeyDown.bind(this);
        this.onKeyUp = this.onKeyUp.bind(this);
        this.inputOnKeyDown = this.inputOnKeyDown.bind(this);
        this.onTab = this.onTab.bind(this);
        this.onShiftTab = this.onShiftTab.bind(this);
        this.getListAtPath = this.getListAtPath.bind(this);
        this.focusOnCurrent = this.focusOnCurrent.bind(this);
        this.toFixedFormat = this.toFixedFormat.bind(this);
        this.convert = this.convert.bind(this);
        this.backspace = this.backspace.bind(this);
        this.handleUpdate = this.handleUpdate.bind(this);
  }

  async componentDidMount () {
    this.focusOnCurrent();

    const charges = (await api.scry<ChargeUpdateInitial>(scryCharges))
    .initial;
    const unitTypes: string[] = (await api.scry({app: "abacus", path: "/units"})).types;
    const unitsOfType: Map<string, UnitOption[]> = new Map<string, UnitOption[]>();
    for (var unitType of unitTypes) {
        unitsOfType.set(unitType, 
            ((await api.scry({app: "abacus", path: `/units/${unitType}`})).units as Unit[]).map(
                (value: Unit, idx: number) => ({
                    label: `${value.name} (${value.symbol})`,
                    value:  value.name,
                    idx: idx,
                    symbol: value.symbol,
                })
            ));
    }

    if (this.state.mode === "calculate") {
        window.addEventListener("keydown", this.onKeyDown);
        window.addEventListener("keyup", this.onKeyUp);
    }

    //get theme
    try {
        api.subscribe({
            app: "spaces",
            path: `/spaces/~${api.ship}/our`,
            event: this.handleUpdate,
            err: () => console.log("rejected"),
            quit: () => console.log("kicked"),
        });
    } catch {
        console.log("sub failed");
    }

    //console.log(await api.scry({app: "spaces", path: `/~${api.ship}/our`}));
    // console.log(makeCSSVars(theme));

    this.setState({
        apps: charges,
        unitTypes: unitTypes,
        unitsOfType: unitsOfType,
    });
  }

  handleUpdate(upd: any) {
    const newTheme = upd["replace"] || upd["remote-space"]
    if (newTheme !== undefined) {
        var settings = {...this.state.settings};
        settings.theme.provided = newTheme.space.theme as ProvidedTheme;
        settings.theme.colors = settings.theme.provided.mode === "light" ? lightColors : darkColors;
        console.log(settings)
        this.setState({
            settings: settings,
        });
    }
  }

  focusOnCurrent() {
    const rawExprs: {curExpr: Expr, allExprs: Expr[]} | undefined = this.getExprAtPath(this.state.inputPath);
    if (rawExprs !== undefined) {
        const curExpr: InputExpr | null = (rawExprs as {curExpr: Expr, allExprs: Expr[]}).curExpr.expr as InputExpr;
        if (curExpr?.ref?.current !== null) {
            curExpr.ref.current.focus();
            curExpr.ref.current.selectionEnd = this.state.caretPos;
        }
    }
  }

  onKeyUp(e: KeyboardEvent) {
    const newKeysDown: string[] = Object.assign([], this.state.keysDown);
    const toRemove = newKeysDown.lastIndexOf(e.key);
    if (toRemove !== undefined) {
        newKeysDown.splice(toRemove, 1)
    }
    this.setState({
        keysDown: newKeysDown,
    });
  }

  onKeyDown(e: KeyboardEvent) {
    //use autoFocus and focus on inputPath
    //if caretPos === 0, ArrowLeft acts like shift-tab, if caretPos === curInput.length, ArrowRight acts like tab
    //ArrowDown: if in string then go to end of encompassing expr (normal, num, denom), if in num then go to end of denum
    //ArrowUp: if in string then go to start of encompassing expr ('')                , if in denom then go to end of num
    //Tab: go to next expr, if at last and in num go to denom
    //Shift-tab: got to prev expr, if at first and in denom for to num 
    //make Frac take last expr as num if it exists

    const newKeysDown: string[] = Object.assign([], this.state.keysDown);
    newKeysDown.push(e.key);
    this.setState({
        keysDown: newKeysDown,
    })
    switch (e.key) {
        case "0":
        case "1":
        case "2":
        case "3":
        case "4":
        case "5":
        case "6":
        case "7":
        case "8":
        case "9":
        case "+":
        case "-":
        case "*":
        case "x":
        case "%":
        case ".":
        case ")":
        case "(":
            this.buttonInput(e.key)();
            break;
        case "Enter":
            this.equals();
            break;
        case "/":
            this.insertFraction();
            break;
        case "ArrowLeft":
            this.onShiftTab();
            break;
        case "Backspace":
            if (this.state.caretPos !== 0) {
                this.focusOnCurrent();
                return;
            }
            this.backspace();
            break;
        case "ArrowRight":
            this.onTab();
            break;
        case "Tab":
            //use keysDown to detect shift, call Arrow[Right/Left] accordingly
            if (this.state.keysDown.find((v: string) => v === "Shift")) {
                this.onShiftTab();
            } else {
                this.onTab();
            }
            break;
        default:
            return;
    }
    //only prevent if already handled
    e.preventDefault();
  }

  onShiftTab() {
    // console.log("shift-tab");
    //need two levels up; list containing list containing curExpr
    //special case for only one level the

    //need to account for caretPos as well

    const newInputPath: number[] = Object.assign([], this.state.inputPath);
    var caretPos: number = this.state.caretPos;

    if (newInputPath.length === 1) {
        if (newInputPath[0] > 0) {
            if (this.state.exprs[newInputPath[0] - 1].type === ExprType.Input) {
                newInputPath[0] = newInputPath[0] - 1;
                caretPos = (this.state.exprs[newInputPath[0]].expr as InputExpr).value.length;
            } else {
                const prevFrac: FracExpr = this.state.exprs[newInputPath[0] - 1].expr as FracExpr;
                if (prevFrac.d.length === 0) {
                    //console.log("empty denominator");;
                    return;
                }
                if (prevFrac.d[prevFrac.d.length - 1].type !== ExprType.Input) {
                    //console.log("unexpected frac");
                    return;
                }
                newInputPath.splice(0, 1, newInputPath[0] - 1, 1, prevFrac.d.length - 1);
                caretPos = (prevFrac.d[prevFrac.d.length - 1].expr as InputExpr).value.length;
            }
        }
    } else {
        const newExprs: Expr[] = this.getExprsCopy();
        let curList: Expr[] = newExprs;
    
        //follow path to list containing list contiaining curExpr
        for(let i = 0; i < (newInputPath.length - 3); i += 2) {
            if(curList[newInputPath[i]].type === ExprType.Input) {
                //console.log("unexpected string " + i);
                return;
            }
            const curFrac: FracExpr = curList[newInputPath[i]].expr as FracExpr;
            curList = newInputPath[i + 1] === 0 ? curFrac.n : curFrac.d;
        }
    
        let containingFrac: FracExpr = curList[newInputPath[newInputPath.length - 3]].expr as FracExpr;
        let containingList: Expr[] = newInputPath[newInputPath.length - 2] === 0 ? containingFrac.n : containingFrac.d;
    
        if (newInputPath[newInputPath.length - 1] > 0) {
            if (containingList[newInputPath[newInputPath.length - 1] - 1].type === ExprType.Input) {
                caretPos = (containingList[newInputPath[newInputPath.length - 1] - 1].expr as InputExpr).value.length;
                newInputPath.splice(newInputPath.length - 1, 1, newInputPath[newInputPath.length - 1] - 1);
            } else {
                const prevFrac: FracExpr = containingList[newInputPath[newInputPath.length - 1] - 1].expr as FracExpr;
                if (prevFrac.d.length === 0) {
                    //console.log("empty denominator");
                    return;
                }
                if (prevFrac.d[prevFrac.d.length - 1].type !== ExprType.Input) {
                    //console.log("unexpected frac");
                    return;
                }
                newInputPath.splice(newInputPath.length - 1, 1, newInputPath[newInputPath.length - 1] - 1, 1, prevFrac.d.length -1);
                caretPos = (prevFrac.d[prevFrac.d.length - 1].expr as InputExpr).value.length;
            }
        } else if (newInputPath[newInputPath.length - 2] === 0) {
            //in numerator; go to previous expr in outer list
            if (newInputPath[newInputPath.length - 3] > 0) {
                // console.log(curList);
                if (curList[newInputPath[newInputPath.length - 3] - 1].type === ExprType.Input) {
                    caretPos = (curList[newInputPath[newInputPath.length - 3] - 1].expr as InputExpr).value.length;
                    newInputPath.splice(newInputPath.length - 3, 3, newInputPath[newInputPath.length - 3] - 1);
                } else {
                    const prevFrac: FracExpr = curList[newInputPath[newInputPath.length - 3] - 1].expr as FracExpr;
                    if (prevFrac.d.length === 0) {
                        //console.log("empty denominator");
                        return;
                    }
                    if (prevFrac.d[prevFrac.d.length - 1].type !== ExprType.Input) {
                        //console.log("unexpected frac");
                        return;
                    }
                    newInputPath.splice(newInputPath.length - 3, 3, newInputPath[newInputPath.length - 3] - 1, 1, prevFrac.d.length - 1);
                    caretPos = (prevFrac.d[prevFrac.d.length - 1].expr as InputExpr).value.length;
                }
            }
        } else if (newInputPath[newInputPath.length - 2] === 1) {
            if (containingFrac.n.length === 0) {
                //console.log("empty numerator");
                return;
            }
            if (containingFrac.n[containingFrac.n.length - 1].type !== ExprType.Input) {
                //console.log("unexpected frac");
                return;
            }
            newInputPath.splice(newInputPath.length - 2, 2, 0, containingFrac.n.length - 1);
            caretPos = (containingFrac.n[containingFrac.n.length - 1].expr as InputExpr).value.length;
        }
    }

    this.setState({
        inputPath: newInputPath,
        caretPos: caretPos,
    }, () => this.focusOnCurrent());
  }

  onTab() {
    // console.log("tab");

    //need two levels up; list containing list containing curExpr
    //special case for only one level the

    //need to account for caretPos as well

    const newInputPath: number[] = Object.assign([], this.state.inputPath);
    // var caretPos: number = this.state.caretPos;

    if (newInputPath.length === 1) {
        if (newInputPath[0] < (this.state.exprs.length - 1)) {
            if (this.state.exprs[newInputPath[0] + 1].type === ExprType.Input) {
                newInputPath[0] = newInputPath[0] + 1;
            } else {
                newInputPath.splice(0, 1, newInputPath[0] + 1, 0, 0);
            }
        }
    } else {
        const newExprs: Expr[] = this.getExprsCopy();
        let curList: Expr[] = newExprs;
    
        //follow path to list containing list contiaining curExpr
        for(let i = 0; i < (newInputPath.length - 3); i += 2) {
            if(curList[newInputPath[i]].type === ExprType.Input) {
                //console.log("unexpected string " + i);
                return;
            }
            const curFrac: FracExpr = curList[newInputPath[i]].expr as FracExpr;
            curList = newInputPath[i + 1] === 0 ? curFrac.n : curFrac.d;
        }
    
        let containingFrac: FracExpr = curList[newInputPath[newInputPath.length - 3]].expr as FracExpr;
        let containingList: Expr[] = newInputPath[newInputPath.length - 2] === 0 ? containingFrac.n : containingFrac.d;
    
        if (newInputPath[newInputPath.length - 1] < (containingList.length - 1)) {
            if (containingList[newInputPath[newInputPath.length - 1] + 1].type === ExprType.Input) {
                newInputPath.splice(newInputPath.length - 1, 1, newInputPath[newInputPath.length - 1] + 1);
            } else {
                newInputPath.splice(newInputPath.length - 1, 1, newInputPath[newInputPath.length - 1] + 1, 0, 0);
            }
        } else if (newInputPath[newInputPath.length - 2] === 0) {
            //in numerator; go to denominator
            //need to 
           newInputPath.splice(newInputPath.length - 2, 2, 1, 0);
        } else if (newInputPath[newInputPath.length - 2] === 1) {
            //in denominator, go to next expr in curList
            if (newInputPath[newInputPath.length - 3] < (curList.length - 1)) {
                if (curList[newInputPath[newInputPath.length - 3] + 1].type === ExprType.Input) {
                    newInputPath.splice(newInputPath.length - 3, 3, newInputPath[newInputPath.length - 3] + 1);
                } else {
                    newInputPath.splice(newInputPath.length - 3, 3, newInputPath[newInputPath.length - 3] + 1, 0, 0);
                }
            }
        }
    }

    this.setState({
        inputPath: newInputPath,
        caretPos: 0,
    }, () => this.focusOnCurrent());
  }

  backspace () {
    //remove current expr
    //if expr was last in numerator or denominator, replace entire frac with remaining
    //need two levels up like (shift-)tab

    const newInputPath: number[] = Object.assign([], this.state.inputPath);
    const newExprs: Expr[] = this.getExprsCopy();
    var caretPos: number = this.state.caretPos;

    if (newInputPath.length === 1) {
        if (newInputPath[0] > 0) {
            if (newExprs[newInputPath[0] - 1].type === ExprType.Input) {
                newExprs.splice(newInputPath[0], 1);
                newInputPath[0] = newInputPath[0] - 1;
                caretPos = (newExprs[newInputPath[0]].expr as InputExpr).value.length;
            } else {
                const prevFrac: FracExpr = newExprs[newInputPath[0] - 1].expr as FracExpr;
                if (prevFrac.d.length === 0) {
                    //console.log("empty denominator");;
                    return;
                }
                if (prevFrac.d[prevFrac.d.length - 1].type !== ExprType.Input) {
                    //console.log("unexpected frac");
                    return;
                }
                // newExprs.splice(newInputPath[0], 1);
                newInputPath.splice(0, 1, newInputPath[0] - 1, 1, prevFrac.d.length - 1);
                caretPos = (prevFrac.d[prevFrac.d.length - 1].expr as InputExpr).value.length;
            }
        }
    } else {
        let curList: Expr[] = newExprs;
    
        //follow path to list containing list contiaining curExpr
        for(let i = 0; i < (newInputPath.length - 3); i += 2) {
            if(curList[newInputPath[i]].type === ExprType.Input) {
                //console.log("unexpected string " + i);
                return;
            }
            const curFrac: FracExpr = curList[newInputPath[i]].expr as FracExpr;
            curList = newInputPath[i + 1] === 0 ? curFrac.n : curFrac.d;
        }
    
        let containingFrac: FracExpr = curList[newInputPath[newInputPath.length - 3]].expr as FracExpr;
        let containingList: Expr[] = newInputPath[newInputPath.length - 2] === 0 ? containingFrac.n : containingFrac.d;

        if (newInputPath[newInputPath.length - 1] > 0) {
            if (containingList[newInputPath[newInputPath.length - 1] - 1].type === ExprType.Input) {
                caretPos = (containingList[newInputPath[newInputPath.length - 1] - 1].expr as InputExpr).value.length;
                containingList.splice(newInputPath[newInputPath.length - 1], 1);
                newInputPath.splice(newInputPath.length - 1, 1, newInputPath[newInputPath.length - 1] - 1);
            } else {
                const prevFrac: FracExpr = containingList[newInputPath[newInputPath.length - 1] - 1].expr as FracExpr;
                if (prevFrac.d.length === 0) {
                    //console.log("empty denominator");
                    return;
                }
                if (prevFrac.d[prevFrac.d.length - 1].type !== ExprType.Input) {
                    //console.log("unexpected frac");
                    return;
                }
                containingList.splice(newInputPath[newInputPath.length - 1], 1);
                newInputPath.splice(newInputPath.length - 1, 1, newInputPath[newInputPath.length - 1] - 1, 1, prevFrac.d.length -1);
                caretPos = (prevFrac.d[prevFrac.d.length - 1].expr as InputExpr).value.length;
            }
        } else if (newInputPath[newInputPath.length - 2] === 0) {
            //in numerator; go to previous expr in outer list, delete frac, append denom
            if (newInputPath[newInputPath.length - 3] > 0) {
                // console.log(curList);
                if (curList[newInputPath[newInputPath.length - 3] - 1].type === ExprType.Input) {
                    caretPos = (curList[newInputPath[newInputPath.length - 3] - 1].expr as InputExpr).value.length;
                    curList.splice(newInputPath[newInputPath.length - 3], 3, ...containingFrac.d);
                    newInputPath.splice(newInputPath.length - 3, 3, newInputPath[newInputPath.length - 3] - 1);
                } else {
                    const prevFrac: FracExpr = curList[newInputPath[newInputPath.length - 3] - 1].expr as FracExpr;
                    if (prevFrac.d.length === 0) {
                        //console.log("empty denominator");
                        return;
                    }
                    if (prevFrac.d[prevFrac.d.length - 1].type !== ExprType.Input) {
                        //console.log("unexpected frac");
                        return;
                    }
                    curList.splice(newInputPath[newInputPath.length - 3], 3, ...containingFrac.d);
                    newInputPath.splice(newInputPath.length - 3, 3, newInputPath[newInputPath.length - 3] - 1, 1, prevFrac.d.length - 1);
                    caretPos = (prevFrac.d[prevFrac.d.length - 1].expr as InputExpr).value.length;
                }
            }
        } else if (newInputPath[newInputPath.length - 2] === 1) {
            if (newInputPath[newInputPath.length - 3] > 0) {
                // console.log(curList);
                if (curList[newInputPath[newInputPath.length - 3] - 1].type === ExprType.Input) {
                    caretPos = (curList[newInputPath[newInputPath.length - 3] - 1].expr as InputExpr).value.length;
                    curList.splice(newInputPath[newInputPath.length - 3], 3, ...containingFrac.n);
                    newInputPath.splice(newInputPath.length - 3, 3, newInputPath[newInputPath.length - 3] - 1);
                } else {
                    const prevFrac: FracExpr = curList[newInputPath[newInputPath.length - 3] - 1].expr as FracExpr;
                    if (prevFrac.d.length === 0) {
                        //console.log("empty denominator");
                        return;
                    }
                    if (prevFrac.d[prevFrac.d.length - 1].type !== ExprType.Input) {
                        //console.log("unexpected frac");
                        return;
                    }
                    curList.splice(newInputPath[newInputPath.length - 3], 3, ...containingFrac.n);
                    newInputPath.splice(newInputPath.length - 3, 3, newInputPath[newInputPath.length - 3] - 1, 1, prevFrac.d.length - 1);
                    caretPos = (prevFrac.d[prevFrac.d.length - 1].expr as InputExpr).value.length;
                }
            }
        }
    }

    this.setState({
        exprs: newExprs,
        inputPath: newInputPath,
        caretPos: caretPos,
    }, () => this.focusOnCurrent());
  }

  getExpr(exprs: Expr[]) : string {
    let expr: string = "";
    for(let i = 0; i < exprs.length; i++) {
        if (exprs[i].type === ExprType.Input) {
            expr += (exprs[i].expr as InputExpr).value;
        } else {
            const frac: FracExpr = exprs[i].expr as FracExpr;
            expr += `((${this.getExpr(frac.n)})/(${this.getExpr(frac.d)}))`;
        }
    }

    return expr;
  }

  toFixedFormat(num: number) : string {
    //TODO?: move to backend? precision setting + processing seems like an intrinsic thing
    if (num.toString().indexOf(".") !== undefined) {
        const str: string = num.toFixed(this.state.settings.precision);
        const matches = str.match(/(.*\..*?)0+$/);
        if (matches === null) {
            return str;
        }
        if (matches[1][matches[1].length - 1] === ".") {
            return matches[1].substring(0, matches[1].length - 1);
        }
        return matches[1];
    }
    return num.toString();
  }

  async equals (/*e: React.MouseEvent<HTMLButtonElement>*/) {
    let expr: string = this.getExpr(this.state.exprs);
    expr = expr.replace(/\s/g, "");
    //Seems like you have to double encode?
    expr = this.doubleEncode(expr);// encodeURIComponent(encodeURIComponent(expr));
    const path = `/eval/${expr}`;
    const res: Answer = await api.scry({
        app: "abacus",
        path: path,
    });

    const resStr = this.toFixedFormat(res.ans);

    this.setState({
        exprs: [{type: ExprType.Input, expr: {value: resStr, ref: React.createRef<HTMLInputElement>()}}],
        prevExprs: this.state.exprs,
        inputPath: [0],
        caretPos: resStr.length,
    });
  }

  getExprsCopy() {
    let newExprs: Expr[] = [];
    this.state.exprs.forEach((val: Expr) => newExprs.push(Object.assign({}, val)));
    return newExprs;
  }

  getExprAtPath (path: number[]) : {curExpr: Expr, allExprs: Expr[]} | undefined {
    if (path.length === 0) {
        return;
    }
    let newExprs: Expr[] = this.getExprsCopy();
    let curExpr: Expr = newExprs[path[0]];
    for(let i = 1; i < path.length; i += 2) {
        if (curExpr.type === ExprType.Input) {
            //console.log("error: not a frac");
            return;
        }
        if (path[i] === 0) {
            curExpr = (curExpr.expr as FracExpr).n[path[i + 1]];
        } else if(path[i] === 1) {
            curExpr = (curExpr.expr as FracExpr).d[path[i + 1]];
        } else {
            //console.log("error: invalid frac idx");
            return;
        }
    }
    if (curExpr.type !== ExprType.Input) {
        //console.log("not a string at path end");
        return;
    }
    return {curExpr: curExpr, allExprs: newExprs};
  }

  setValAtPath (path: number[], process: (curVal: string) => {newValue: string, newCaretPos: number}) {
    const rawExprs: {curExpr: Expr, allExprs: Expr[]} | undefined = this.getExprAtPath(path);
    if (rawExprs === undefined) {
        //console.log("no exprs")
        return;
    }
    const exprs: {curExpr: Expr, allExprs: Expr[]} = rawExprs as {curExpr: Expr, allExprs: Expr[]};
    if (exprs.curExpr.type !== ExprType.Input) {
        //console.log("not a string");
        return;
    }
    const newVals: {newValue: string, newCaretPos: number} = process((exprs.curExpr.expr as InputExpr).value);
    (exprs.curExpr.expr as InputExpr).value = newVals.newValue;
    this.setState({
        exprs: exprs.allExprs,
        caretPos: newVals.newCaretPos,
    }, () => this.focusOnCurrent());
  }

  handleChange(path: number[], e: React.ChangeEvent<HTMLInputElement>) {
    this.setValAtPath(path, () => ({newValue: e.target.value, newCaretPos: e.target.selectionEnd || 0 /*this.state.caretPos*/}));
  }

  //used to pass a select few events to the document/window
  //level onKeyDown handler and send the rest to the regular
  //onChange handler
  inputOnKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (["/", "Tab", "Enter"].find((v: string) => v === e.key) !== undefined) {
        this.setState({
            caretPos: e.target.selectionEnd as number,
        });
        e.target.blur();
        return;
    }
    if (e.key === "ArrowLeft") {
        if (e.target.selectionEnd === 0) {
            e.target.blur();
            return;
        }
        if (e.target.selectionEnd !== null) {
            this.setState({
                caretPos: (e.target.selectionEnd as number) - 1,
            });
        }
    }
    if (e.key === "ArrowRight") {
        if (e.target.selectionEnd === e.target.value.length) {
            e.target.blur();
            return;
        }
        if (e.target.selectionEnd !== null) {
            this.setState({
                caretPos: (e.target.selectionEnd as number) + 1,
            });
        }
    }
    if (e.key === "Backspace" && e.target.selectionEnd === 0) {
        // console.log("input backspace")
        // this.backspace();
        return;
    }
    if (e.key === "Shift") {
        const newKeysDown: string[] = Object.assign([], this.state.keysDown);
        newKeysDown.push("Shift");
        this.setState({
            keysDown: newKeysDown,
        });
    }
    e.stopPropagation();
  }

  handleFocus(path: number[]/*, e: React.FocusEvent<HTMLInputElement>*/) {
    this.setState({
        inputPath: path,
        // caretPos: e.target.value.length,
    });
  }

  onMouseOut ([], e: React.MouseEvent<HTMLInputElement>) {
    this.setState({
        caretPos: (e.target as any).selectionEnd as number,
    });
  }

  handlePlaceholderClick(path: number[]/*, e: React.MouseEvent<HTMLDivElement>*/) {
    this.setState({
        inputPath: path,
        caretPos: 0,
    })
  }

  buttonInput(s: string): () => void {
    var onchange: ()=>void = () => {
        //TODO: add cursor pos and insert s at that pos
        this.setValAtPath(this.state.inputPath, (curVal: string) => {
            return {
                newValue: curVal.substring(0, this.state.caretPos) + s + curVal.substring(this.state.caretPos, curVal.length),
                newCaretPos: this.state.caretPos + 1,
            };
        });
    };
    onchange = onchange.bind(this);
    return onchange;
  }

  clear() {
    this.setState({
        exprs: [{type: ExprType.Input, expr: {value: "", ref: React.createRef<HTMLInputElement>()}}],
        prevExprs: [],
        inputPath: [0],
        caretPos: 0,
    })
  }

  getListAtPath() : {curExprs: Expr[], allExprs: Expr[]} | undefined {
    const newExprs: Expr[] = this.getExprsCopy();
    let curList: Expr[] = newExprs;

    //follow path to the current expr/string
    for(let i = 0; i < (this.state.inputPath.length - 1); i += 2) {
        if(curList[this.state.inputPath[i]].type === ExprType.Input) {
            //console.log("unexpected string " + i);
            return;
        }
        const curFrac: FracExpr = curList[this.state.inputPath[i]].expr as FracExpr;
        curList = this.state.inputPath[i + 1] === 0 ? curFrac.n : curFrac.d;
    }

    return {curExprs: curList, allExprs: newExprs};
  }

  insertFraction() {
    /* behaviour
    number immediately following caretPos becomes denominator
    number immediately preceding caretPos becomes numerator
    if only before exists, focus on denominator
    if neither or only after exists, focus on numerator
    if both exist then focus on expr after frac
    */

    const rawList: {curExprs: Expr[], allExprs: Expr[]} | undefined = this.getListAtPath();
    if (rawList === undefined) {
        //console.log("no exprs");
        return;
    }
    const { curExprs, allExprs }: {curExprs: Expr[], allExprs: Expr[]} = rawList as {curExprs: Expr[], allExprs: Expr[]}; 

    const toReplacePos: number = this.state.inputPath[this.state.inputPath.length - 1];
    if (curExprs[toReplacePos].type !== ExprType.Input) {
        //console.log("not a string");
        return;
    }
    const toReplace = (curExprs[toReplacePos].expr as InputExpr).value;

    //get before index of any preceeding number
    var numberBeforePos: number = this.state.caretPos - 1;
    //read %
    if(numberBeforePos >= 0 && numberBeforePos < toReplace.length && toReplace[numberBeforePos] === '%') {
        numberBeforePos--;
    }
    for(; numberBeforePos >= 0 && numberBeforePos < toReplace.length 
        && (toReplace[numberBeforePos].match(/\d/) !== null || toReplace[numberBeforePos] === '.'); numberBeforePos--);

    //get end index of any suceeding number 
    var numberAfterPos: number = this.state.caretPos;
    for(; numberAfterPos >= 0 && numberAfterPos < toReplace.length
        && (toReplace[numberAfterPos].match(/\d/) !== null || toReplace[numberAfterPos] === '.'); numberAfterPos++);
    //read %
    if(numberAfterPos >= 0 && numberAfterPos < toReplace.length && toReplace[numberAfterPos] === '%') {
        numberAfterPos++;
    }

    //get corresponding strings
    const numberBefore: string = toReplace.substring(numberBeforePos + 1, this.state.caretPos) || "";
    const numberAfter: string = toReplace.substring(this.state.caretPos, numberAfterPos) || "";

    //remove current expr/string and insert the fraction
    curExprs.splice(toReplacePos, 1, 
        {type: ExprType.Input, expr: {value: (numberBeforePos >= 0 ? toReplace.substring(0, numberBeforePos + 1) : ""),
            ref: React.createRef<HTMLInputElement>()}},
        {type: ExprType.Frac, 
            expr: {
                n: [{type: ExprType.Input, expr: {value: numberBefore, ref: React.createRef<HTMLInputElement>()}}],
                d: [{type: ExprType.Input, expr: {value: numberAfter, ref: React.createRef<HTMLInputElement>()}}]
            }},
        
    );
    const restAfterNumber: string = numberAfterPos < toReplace.length ? toReplace.substring(numberAfterPos, toReplace.length) : "";
    if (restAfterNumber !== "" || curExprs.length === (toReplacePos + 2)) {
        curExprs.push({type: ExprType.Input, expr: {value: restAfterNumber,
            ref: React.createRef<HTMLInputElement>()}});
    }
    const newInputPath: number[] = Object.assign([], this.state.inputPath);
    if (numberBefore !== "" && numberAfter !== "") {
        newInputPath.splice(newInputPath.length - 1, 1, newInputPath[newInputPath.length-1] + 2);
    } else if (numberBefore !== "") {
        newInputPath.splice(newInputPath.length - 1, 1, newInputPath[newInputPath.length-1] + 1, 1, 0);
    } else {
        newInputPath.splice(newInputPath.length - 1, 1, newInputPath[newInputPath.length-1] + 1, 0, 0);
    }

    this.setState({
        exprs: allExprs,
        inputPath: newInputPath,
        //TODO: check this
        caretPos: 0,
    }, () => this.focusOnCurrent());
  }

  calcMode() {
    window.addEventListener("keydown", this.onKeyDown);
    window.addEventListener("keyup", this.onKeyUp);
    this.setState({mode: "calculate"});
  }

  convMode() {
    window.removeEventListener("keydown", this.onKeyDown);
    window.removeEventListener("keyup", this.onKeyUp);
    this.setState({mode: "convert"});
  }
  
  unitTypeChange(newValue: unknown/*, actionMeta: ActionMeta<unknown>*/) {
    this.setState({
        unitType: (newValue as {label: string, value: string}).value,
        unit1: undefined,
        unit2: undefined,
        amount1: "",
        amount2: "",
    });
  }

  async unitChange1(newValue: unknown) {
    this.setState({
        unit1: newValue as UnitOption,
    }, () => this.doConvert(true));
  }

  async unitChange2(newValue: unknown) {
    this.setState({
        unit2: newValue as UnitOption,
    }, () => this.doConvert(false));
  }

  async amount1Change(e: React.ChangeEvent<HTMLInputElement>) {
    const amount1: string = e.target.value.trim();

    this.setState({
        amount1: amount1,
    }, amount1 === "" ? undefined : () => this.doConvert(true));
  }

  async amount2Change(e: React.ChangeEvent<HTMLInputElement>) {
    const amount2: string = e.target.value.trim();

    this.setState({
        amount2: amount2,
    }, amount2 === "" ? undefined : () => this.doConvert(false));
  }

  async doConvert(tryFromFirst: boolean) {
    if (this.state.unit1 === undefined || this.state.unit2 === undefined) {
        return;
    }
    if ((tryFromFirst || this.state.amount2.trim() === "") && this.state.amount1.trim() !== "") {
        this.setState({
            amount2: (await this.convert(this.state.amount1.trim(), this.state.unit1, this.state.unit2)),
        });
    } else if (this.state.amount2.trim() !== "") {
        this.setState({
            amount1: (await this.convert(this.state.amount2.trim(), this.state.unit2, this.state.unit1)),
        });
    }
  }

  async convert(amount: string, from: UnitOption, to: UnitOption) : Promise<string> {
    // const path: string = `/convert/${this.state.unitType || "="}/.~${amount}/${from}/${to}`;
    const path: string = `/convert/${this.state.unitType || "="}/.~${amount}/${this.doubleEncode(from.value)}/${this.doubleEncode(to.value)}`;
    return api.scry({app: "abacus", path: path}).then<string>(res => this.toFixedFormat(res.ans));
  }

  doubleEncode (uri: string) : string {
    return encodeURIComponent(encodeURIComponent(uri));
  }

  makeSingleOption(option?: UnitOption) : UnitOption | string{
    if (option === undefined) {
        return "Unit";
    }
    return {
        label: option.symbol,
        value: option.value,
        idx: option.idx,
        symbol: option.symbol,
    };
  }

  render() {
    const modeIsCalc: boolean = this.state.mode.toLowerCase() === "calculate";
    const singleUnit1 = this.makeSingleOption(this.state.unit1);
    const singleUnit2 = this.makeSingleOption(this.state.unit2);
    return (
        <ThemeProvider theme={this.state.settings.theme}>
            <Page>
                <ModeButtonsDiv>
                    <ModeButton text="Calculate" onClick={this.calcMode} selected={modeIsCalc}></ModeButton>
                    <ModeButton text="Convert" onClick={this.convMode} selected={!modeIsCalc}></ModeButton>
                </ModeButtonsDiv>
            {   modeIsCalc ?
                <AbacusBody>
                    <FracInput exprs={this.state.exprs} prevExprs={this.state.prevExprs}
                        onChange={this.handleChange}
                        onKeyDown={this.inputOnKeyDown}
                        onFocus={this.handleFocus}
                        onPlaceholderClick={this.handlePlaceholderClick}
                        onMouseOut={this.onMouseOut}
                        path={this.state.inputPath}
                        />
                    <ButtonGrid>
                        <StyledSquareButton column={1} row={1} onClick={this.clear}><ButtonLabel>C</ButtonLabel></StyledSquareButton>
                        <StyledSquareButton column={2} row={1} onClick={this.insertFraction}>
                            <ButtonLabel>1/2</ButtonLabel>
                        </StyledSquareButton>
                        <StyledSquareButton column={3} row={1} onClick={this.buttonInput("%")}>
                            <ButtonLabel>%</ButtonLabel>
                        </StyledSquareButton>
                        <OpButton column={4} row={1} onClick={this.buttonInput("/")}>
                            <ButtonLabel>{String.fromCharCode(247)}
                        </ButtonLabel></OpButton>
                        <NumberButton column={1} row={2} label="7" onClick={this.buttonInput("7")}/>
                        <NumberButton column={2} row={2} label="8" onClick={this.buttonInput("8")}/>
                        <NumberButton column={3} row={2} label="9" onClick={this.buttonInput("9")}/>
                        <OpButton column={4} row={2} onClick={this.buttonInput("x")}><ButtonLabel>x</ButtonLabel></OpButton>
                        <NumberButton column={1} row={3} label="4" onClick={this.buttonInput("4")}/>
                        <NumberButton column={2} row={3} label="5" onClick={this.buttonInput("5")}/>
                        <NumberButton column={3} row={3} label="6" onClick={this.buttonInput("6")}/>
                        <OpButton column={4} row={3} onClick={this.buttonInput("-")}><ButtonLabel>-</ButtonLabel></OpButton>
                        <NumberButton column={1} row={4} label="1" onClick={this.buttonInput("1")}/>
                        <NumberButton column={2} row={4} label="2" onClick={this.buttonInput("2")}/>
                        <NumberButton column={3} row={4} label="3" onClick={this.buttonInput("3")}/>
                        <OpButton column={4} row={4} onClick={this.buttonInput("+")}><ButtonLabel>+</ButtonLabel></OpButton>
                        <NumberButton column={1} row={5} width={2} label="0" onClick={this.buttonInput("0")}/>
                        <NumberButton column={3} row={5} label="." onClick={this.buttonInput(".")}/>
                        <EqualsButton column={4} row={5} onClick={this.equals}><ButtonLabel>=</ButtonLabel></EqualsButton>
                    </ButtonGrid>
                </AbacusBody>
                :
                <AbacusBody>
                    <UnitTypeDropDown options={this.state.unitTypes.map((value: string) => ({label: value, value: value}))}
                        onChange={this.unitTypeChange} placeholder="Unit Type"
                        value={this.state.unitType && {label: this.state.unitType, value: this.state.unitType}}
                        styles={UnitTypeDropDownStyles(this.state.settings.theme)}/>
                    <MeasureDiv>
                        <AmountInput value={this.state.amount1} onChange={this.amount1Change}/>
                        <UnitDropDownWrapper>
                            <UnitDropDown menuPortalTarget={document.body} menuPosition="fixed" styles={UnitDropDownStyles(this.state.settings.theme, singleUnit1 as UnitOption)}
                                    options={this.state.unitType === undefined ? undefined
                                        : (this.state.unitsOfType.get(this.state.unitType) || [])}
                                    onChange={this.unitChange1} placeholder="Unit" value={singleUnit1}
                            />
                        </UnitDropDownWrapper>
                    </MeasureDiv>
                    <CalcEquals>=</CalcEquals>
                    <MeasureDiv>
                        <AmountInput value={this.state.amount2} onChange={this.amount2Change}/>
                        <UnitDropDownWrapper>
                            <UnitDropDown menuPortalTarget={document.body} menuPosition="fixed" styles={UnitDropDownStyles(this.state.settings.theme, singleUnit2 as UnitOption)}
                                    options={this.state.unitType === undefined ? undefined 
                                        : (this.state.unitsOfType.get(this.state.unitType) || [])}
                                    onChange={this.unitChange2} placeholder="Unit" value={singleUnit2}
                            />
                        </UnitDropDownWrapper>
                    </MeasureDiv>
                </AbacusBody>
            }
            </Page>
        </ThemeProvider>
    )
  }
};
