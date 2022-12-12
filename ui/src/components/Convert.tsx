import styled from "styled-components";
import Select, { StylesConfig } from "react-select";

// font-weight: 400;
// font-size: 14px;
const ConvertDropDown = styled(Select)`
    font-family: var(--rlm-font);
    font-style: normal;
    line-height: 17px;
    font-weight: 400;
    font-size: 14px;
    height: max-content;

    border-radius: 6px;
    margin: auto;
`;

export const UnitTypeDropDown = styled(ConvertDropDown)`
    border: 1px solid ${props => props.theme.colors.border.differentLight};
    margin: 12px auto 40px auto;
    width: 85%;
`;

export const UnitDropDown = styled(ConvertDropDown)`
    display: inline;
    border: none;
`;


interface AmountInputProps {
    value: string,
}

//font-size: 28px;
//flex: 3 1 65%;
export const AmountInput = styled.input<AmountInputProps>`
    font-family: var(--rlm-font);
    font-style: normal;
    font-weight: 500;
    font-size: ${({value}) => 28 / (value.length < 8 ? 1 : (value.length / 8))}px;
    line-height: 33px;
    letter-spacing: 0.04em;

    color: ${props => props.theme.colors.text.dark};
    background: ${props => props.theme.colors.background.white};

    display: inline;
    border: 0px;
    align-text: center;

    min-width: 0px;
    width: 70%;

    margin: 9.5px auto 9.5px 0px;
    padding-left: 12px;
`;

export const MeasureDiv = styled.div`
    margin: auto;

    display: flex;
    justify-content: space-between;

    // align-items: center;
    // padding: 12px;

    background: ${props => props.theme.colors.background.white};
    border: 1px solid ${props => props.theme.colors.border.light};
    backdrop-filter: blur(14px);
    /* Note: backdrop-filter has minimal browser support */

    border-radius: 9px;
    height: 50%;
    width: 85%;
`;

export interface UnitOption {
    label: string,
    value: string,
    idx: number,
    symbol: string,
}

export function UnitDropDownStyles(theme: any, value?: UnitOption) : StylesConfig {
    return {
        // Fixes the overlapping problem of the component
        menuPortal: ({...provided}) => ({
            zIndex: 9999,
            ...provided, 
        }),
        menu: ({ width, backgroundColor, ...css }) => ({
            zIndex: 9999,
            backgroundColor: theme.colors.background.white,
            ...css,
        }),
        singleValue: ({ color, width, maxWidth, minWidth, justifySelf, position, top, transform, backgroundColor, ...otherStyles }) => ({
            width: `${(value === undefined ? 6 : (value as UnitOption).label.length) + 2}ch`,
            color: theme.colors.text.lessMedium,
            minWidth: "0px",
            justifySelf: "flex-end",
            backgroundColor: theme.colors.background.white,
            ...otherStyles,
        }),
        option: ({color, backgroundColor, ...otherStyles}) => ({
            color: theme.colors.text.lessMedium,
            backgroundColor: theme.colors.background.white,
            ...otherStyles,
        }),
        control: ({backgroundColor, ...otherStyles}) => ({
            backgroundColor: theme.colors.background.white,
            ...otherStyles,
        }),
    };
}

export function UnitTypeDropDownStyles(theme: any) : StylesConfig {
    return {
        singleValue: ({color, backgroundColor, ...otherStyles}) => ({
            color: theme.colors.text.dark,
            backgroundColor: theme.colors.background.white,
            ...otherStyles,
        }),
        option: ({color, backgroundColor, ...otherStyles}) => ({
            color: theme.colors.text.dark,
            backgroundColor: theme.colors.background.white,
            ...otherStyles,
        }),
        control: ({backgroundColor, ...otherStyles}) => ({
            backgroundColor: theme.colors.background.white,
            ...otherStyles,
        }),
        menu: ({ width, backgroundColor, ...otherStyles }) => ({
            backgroundColor: theme.colors.background.white,
            ...otherStyles,
        }),
    };
}

export const UnitDropDownWrapper = styled.div`
    flex: 1 1 max-content;
    margin: 9.5px 12px;
`;
